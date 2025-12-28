"""
Extractor mejorado de Forex Factory usando Undetected Chromedriver
"""

import time
import random
import json
import undetected_chromedriver as uc  # LIBRERÍA CLAVE
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup
from deep_translator import GoogleTranslator

def random_sleep(min_seconds=2, max_seconds=5):
    """Duerme una cantidad aleatoria de tiempo para simular humano"""
    time.sleep(random.uniform(min_seconds, max_seconds))

def traducir_texto(texto, idioma_destino='es'):
    """
    Traduce texto al español usando Google Translator
    Maneja textos largos dividiéndolos en chunks
    """
    try:
        if not texto or texto.strip() == "":
            return texto
        
        if len(texto) > 4500:
            chunks = [texto[i:i+4500] for i in range(0, len(texto), 4500)]
            traduccion = ""
            for chunk in chunks:
                traduccion += GoogleTranslator(source='auto', target=idioma_destino).translate(chunk)
            return traduccion
        else:
            return GoogleTranslator(source='auto', target=idioma_destino).translate(texto)
    except Exception as e:
        print(f"⚠️ Error traduciendo: {e}")
        return texto

def traducir_noticia(noticia):
    """
    Traduce los campos de texto de una noticia al español
    """
    noticia_traducida = noticia.copy()
    
    if noticia_traducida.get('title'):
        noticia_traducida['title'] = traducir_texto(noticia_traducida['title'])
    
    if noticia_traducida.get('content'):
        noticia_traducida['content'] = traducir_texto(noticia_traducida['content'])
    
    return noticia_traducida

def extract_news_details(driver, href):
    """
    Extrae detalles con comportamiento humanizado
    """
    try:
        full_url = f"https://www.forexfactory.com{href}"
        driver.get(full_url)
        
        # 1. Espera aleatoria inicial (simula carga y lectura visual)
        # random_sleep(2, 4) 
        
        # 2. Simular Scroll suave hacia abajo (muy importante para evitar detección)
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight/2);")
        time.sleep(0.5)
        
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.CLASS_NAME, 'news__copy'))
        )
        
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        
        # Extracción (Tu lógica original estaba bien, la mantenemos)
        content = ''
        new_origin = ''
        image = ''
        publication_date = ''
        
        content_elem = soup.find('p', class_='news__copy')
        if content_elem:
            content = content_elem.get_text(strip=True)
        
        link_elem = soup.select_one('p.news__copy a[href*="http"]')
        if link_elem:
            new_origin = link_elem.get('href', '')
        
        img_elem = soup.find('img', class_='attach')
        if img_elem:
            image = img_elem.get('src', '')
        
        date_elem = soup.find('span', style=lambda x: x and 'white-space: nowrap' in x)
        if date_elem:
            publication_date = date_elem.get_text(strip=True)
            
        return {
            'content': content,
            'new_origin': new_origin,
            'image': image,
            'publication_date': publication_date
        }

    except Exception as e:
        print(f"⚠️ Error leve en {href}: {e}")
        return None  # Retornamos None para filtrar después

def extract_forex_links(url):
    options = uc.ChromeOptions()
    # options.add_argument('--headless') # Ojo: Headless en UC a veces es detectado más fácil. Úsalo solo si es necesario.
    options.add_argument('--no-sandbox')
    
    # Iniciamos el driver "indetectable"
    driver = uc.Chrome(options=options)
    
    try:
        print(f"🌐 Accediendo al feed principal...")
        driver.get(url)
        
        print("⏳ Esperando carga inicial...")
        WebDriverWait(driver, 10).until(
            EC.presence_of_all_elements_located((By.CLASS_NAME, 'flexposts__item'))
        )
        random_sleep(3, 6) # Espera larga inicial
        
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        
        all_links = []
        seen_hrefs = set()
        news_items = soup.select('.flexposts__item:not(.comment)')
        
        # Lógica de extracción de links (limitada a 5 para prueba, quita el [:5] en producción)
        for item in news_items: 
            link_elem = item.select_one('.flexposts__title a')
            if not link_elem: continue
            
            href = link_elem.get('href', '')
            if not href or '#post' in href: continue
            
            if href not in seen_hrefs:
                seen_hrefs.add(href)
                title = link_elem.get_text(strip=True)
                all_links.append({'href': href, 'title': title})
        
        print(f"📰 Encontrados {len(all_links)} enlaces. Comenzando extracción detallada...")
        
        final_news = []
        
        # BUCLE PRINCIPAL DE EXTRACCIÓN
        for idx, news in enumerate(all_links):
            print(f"  [{idx+1}/{len(all_links)}] Leyendo: {news['title'][:40]}...")
            
            details = extract_news_details(driver, news['href'])
            
            if details:
                news_item = {
                    'href': news['href'],
                    'title': news['title'],
                    **details
                }
                final_news.append(news_item)
            
            # 3. PAUSA CRÍTICA ENTRE NOTICIAS
            # Si no pausas aquí, ForexFactory te bloqueará por "rate limit"
            print("     💤 Esperando antes de la siguiente...")
            random_sleep(4, 8) 
            
        return final_news
        
    except Exception as e:
        print(f"❌ Error fatal: {e}")
        return []
    finally:
        driver.quit()

def main():
    FOREX_URL = "https://www.forexfactory.com/news"
    data = extract_forex_links(FOREX_URL)
    
    if data:
        print(f"\n🔄 Traduciendo {len(data)} noticias al español...")
        data_traducida = [traducir_noticia(noticia) for noticia in data]
        
        with open('forex_news_safe.json', 'w', encoding='utf-8') as f:
            json.dump(data_traducida, f, ensure_ascii=False, indent=2)
        print(f"\n✅ Éxito: {len(data_traducida)} noticias traducidas y guardadas.")

if __name__ == "__main__":
    main()
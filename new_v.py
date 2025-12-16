"""
Extractor mejorado de enlaces de Forex Factory con técnicas anti-detección
"""

import time
import random
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from bs4 import BeautifulSoup
import json

def setup_driver():
    """
    Configura el driver de Chrome con opciones anti-detección
    """
    chrome_options = Options()
    
    # Opciones básicas anti-detección
    chrome_options.add_argument('--disable-blink-features=AutomationControlled')
    chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
    chrome_options.add_experimental_option('useAutomationExtension', False)
    
    # User agent realista y actualizado
    chrome_options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36')
    
    # Opciones adicionales para parecer más humano
    chrome_options.add_argument('--disable-dev-shm-usage')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-gpu')
    chrome_options.add_argument('--window-size=1920,1080')
    chrome_options.add_argument('--start-maximized')
    chrome_options.add_argument('--disable-web-security')
    chrome_options.add_argument('--allow-running-insecure-content')
    
    # Preferencias para parecer un navegador real
    prefs = {
        'profile.default_content_setting_values': {
            'notifications': 2,
            'geolocation': 2,
        },
        'profile.managed_default_content_settings': {
            'images': 2  # Desactivar imágenes para mayor velocidad (opcional)
        }
    }
    chrome_options.add_experimental_option('prefs', prefs)
    
    driver = webdriver.Chrome(options=chrome_options)
    
    # Ejecutar scripts anti-detección
    driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
    driver.execute_cdp_cmd('Network.setUserAgentOverride', {
        "userAgent": 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
    })
    driver.execute_cdp_cmd('Page.addScriptToEvaluateOnNewDocument', {
        'source': '''
            delete Object.getPrototypeOf(navigator).webdriver
            Object.defineProperty(navigator, 'plugins', {
                get: () => [1, 2, 3, 4, 5]
            });
            Object.defineProperty(navigator, 'languages', {
                get: () => ['en-US', 'en', 'es']
            });
            window.chrome = {
                runtime: {}
            };
        '''
    })
    
    return driver

def human_delay(min_seconds=1, max_seconds=3):
    """
    Simula pausas humanas aleatorias
    """
    time.sleep(random.uniform(min_seconds, max_seconds))

def scroll_smoothly(driver, scrolls=3):
    """
    Simula scroll humano
    """
    for _ in range(scrolls):
        scroll_amount = random.randint(200, 500)
        driver.execute_script(f"window.scrollBy(0, {scroll_amount});")
        time.sleep(random.uniform(0.3, 0.8))

def extract_news_details(driver, href, retry_count=0):
    """
    Extrae detalles de una noticia individual con reintentos
    """
    max_retries = 2
    
    try:
        full_url = f"https://www.forexfactory.com{href}"
        print(f"    🔗 Accediendo a: {full_url}")
        
        driver.get(full_url)
        
        # Espera más realista
        human_delay(2, 4)
        
        # Scroll suave para simular lectura
        scroll_smoothly(driver, scrolls=2)
        
        # Esperar contenido específico
        try:
            WebDriverWait(driver, 15).until(
                EC.presence_of_element_located((By.CLASS_NAME, 'news__copy'))
            )
        except:
            print(f"    ⚠️  No se encontró news__copy, intentando alternativa...")
            human_delay(3, 5)
        
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        
        content = ''
        new_origin = ''
        image = ''
        publication_date = ''
        
        # Extraer contenido
        content_elem = soup.find('p', class_='news__copy')
        if content_elem:
            content = content_elem.get_text(strip=True)
        else:
            # Alternativa: buscar en otros contenedores
            content_elem = soup.find('div', class_='news__content')
            if content_elem:
                content = content_elem.get_text(strip=True)
        
        # Extraer enlace origen
        link_elem = soup.select_one('p.news__copy a[href*="http"]')
        if not link_elem:
            link_elem = soup.select_one('a[href*="http"]')
        if link_elem:
            new_origin = link_elem.get('href', '')
        
        # Extraer imagen
        img_elem = soup.find('img', class_='attach')
        if not img_elem:
            img_elem = soup.find('img', src=True)
        if img_elem:
            image = img_elem.get('src', '')
        
        # Extraer fecha
        date_elem = soup.find('span', style=lambda x: x and 'white-space: nowrap' in x)
        if not date_elem:
            date_elem = soup.find('time')
        if date_elem:
            publication_date = date_elem.get_text(strip=True)
        
        print(f"    ✅ Contenido extraído exitosamente")
        
        return {
            'content': content,
            'new_origin': new_origin,
            'image': image,
            'publication_date': publication_date
        }
        
    except Exception as e:
        print(f"    ❌ Error extrayendo detalles de {href}: {e}")
        
        # Reintentar si es posible
        if retry_count < max_retries:
            print(f"    🔄 Reintentando ({retry_count + 1}/{max_retries})...")
            human_delay(5, 8)  # Pausa más larga antes de reintentar
            return extract_news_details(driver, href, retry_count + 1)
        
        return {
            'content': '',
            'new_origin': '',
            'image': '',
            'publication_date': ''
        }

def extract_forex_links(url, max_news=None):
    """
    Extrae enlaces de noticias desde la página principal y sus detalles
    max_news: límite de noticias a procesar (None = todas)
    """
    driver = setup_driver()
    
    try:
        print(f"🌐 Accediendo a: {url}")
        driver.get(url)
        
        # Espera inicial más larga
        human_delay(3, 5)
        
        print("⏳ Esperando contenido...")
        WebDriverWait(driver, 15).until(
            EC.presence_of_all_elements_located((By.CLASS_NAME, 'flexposts__item'))
        )
        
        # Scroll para simular navegación humana
        scroll_smoothly(driver, scrolls=4)
        human_delay(2, 3)
        
        print("📝 Extrayendo enlaces...")
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        
        all_links = []
        seen_hrefs = set()
        
        news_items = soup.select('.flexposts__item:not(.comment)')
        
        for item in news_items:
            link_elem = item.select_one('.flexposts__title a')
            if not link_elem:
                continue
            
            href = link_elem.get('href', '')
            if not href or '#post' in href:
                continue
            
            if href not in seen_hrefs:
                seen_hrefs.add(href)
                title = link_elem.get_text(strip=True)
                all_links.append({
                    'href': href,
                    'title': title
                })
        
        # Limitar si se especificó max_news
        if max_news:
            all_links = all_links[:max_news]
        
        print(f"📰 Encontrados {len(all_links)} enlaces únicos")
        print("🔍 Extrayendo detalles de cada noticia...")
        
        all_news = []
        for idx, news in enumerate(all_links):
            print(f"\n[{idx+1}/{len(all_links)}] Procesando: {news['title'][:60]}...")
            
            details = extract_news_details(driver, news['href'])
            
            news_item = {
                'href': news['href'],
                'title': news['title'],
                'content': details['content'],
                'new_origin': details['new_origin'],
                'image': details['image'],
                'publication_date': details['publication_date']
            }
            all_news.append(news_item)
            
            # Pausa entre solicitudes para parecer humano
            if idx < len(all_links) - 1:
                wait_time = random.uniform(3, 7)
                print(f"    ⏸️  Esperando {wait_time:.1f}s antes de la siguiente...")
                time.sleep(wait_time)
        
        print("\n✅ Extracción completada")
        return all_news
        
    except Exception as e:
        print(f"❌ Error al extraer datos: {e}")
        import traceback
        traceback.print_exc()
        return []
    finally:
        print("🔒 Cerrando navegador...")
        driver.quit()

def main():
    """Función principal"""
    FOREX_URL = "https://www.forexfactory.com/news"
    
    # Limitar a 5 noticias para prueba (quitar max_news=5 para todas)
    print("🚀 Iniciando scraper de Forex Factory")
    print("⚠️  MODO PRUEBA: Procesando solo 5 noticias")
    print("-" * 60)
    
    all_news = extract_forex_links(FOREX_URL, max_news=5)
    
    if all_news:
        output_file = 'forex_news_data.json'
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(all_news, f, ensure_ascii=False, indent=2)
        print(f"\n💾 Datos guardados en: {output_file}")
        print(f"📊 Total de noticias procesadas: {len(all_news)}")
    else:
        print("\n⚠️  No se extrajeron datos")

if __name__ == "__main__":
    main()
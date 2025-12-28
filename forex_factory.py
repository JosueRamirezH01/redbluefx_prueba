from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from deep_translator import GoogleTranslator
from bs4 import BeautifulSoup
import json
import time
from datetime import datetime

def traducir_texto(texto, idioma_destino='es'):
    """
    Traduce texto al español usando Google Translator
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
        print(f"Error traduciendo: {e}")
        return texto

def extract_real_news_links(html):
    """
    Extrae SOLO noticias reales (excluye comentarios/likes) del HTML
    Similar a extractNewsWithTypeInfo del script JS
    """
    soup = BeautifulSoup(html, 'html.parser')
    
    # Buscar TODOS los contenedores de noticias (.flexBox.news)
    all_news_blocks = soup.find_all('div', class_=['flexBox', 'news'])
    
    if not all_news_blocks:
        print('No se encontraron bloques .flexBox.news')
        # Intentar búsqueda alternativa
        all_news_blocks = soup.find_all('div', class_='flexBox')
        print(f'Búsqueda alternativa: {len(all_news_blocks)} bloques .flexBox encontrados')
    else:
        print(f'Se encontraron {len(all_news_blocks)} bloques .flexBox.news')
    
    all_news_links = []
    excluded_count = 0
    
    # Mapear títulos a categorías (como en el script JS)
    category_map = {
        'Breaking News': 'breakingNews',
        'Fundamental Analysis': 'fundamentalAnalysis',
        'Technical Analysis': 'technicalAnalysis',
        'Entertainment News': 'entertainmentNews',
        'Forex Industry News': 'forexIndustryNews',
        'Educational News': 'educationalNews',
        'Latest Stories': 'otherNews',
        'Hot Stories': 'otherNews'
    }
    
    # Iterar sobre cada bloque de noticias
    for block_index, block in enumerate(all_news_blocks):
        # Obtener título del bloque
        title_element = block.find('div', class_='flexTitle')
        if title_element:
            span = title_element.find('span')
            block_title = span.get_text(strip=True) if span else f'Bloque {block_index + 1}'
        else:
            block_title = f'Bloque {block_index + 1}'
        
        # Determinar categoría
        category = 'otherNews'
        is_excluded = False
        
        # Verificar si es una sección a excluir
        if 'Latest Liked' in block_title or 'Comments' in block_title or 'Commented' in block_title:
            category = 'excluded'
            is_excluded = True
            print(f'❌ Bloque EXCLUIDO: "{block_title}"')
            excluded_count += 1
            continue
        else:
            # Buscar coincidencia en el mapeo
            for key, value in category_map.items():
                if key in block_title:
                    category = value
                    break
            print(f'✅ Bloque "{block_title}" -> Categoría: {category}')
        
        # Extraer noticias de este bloque
        flexposts_section = block.find('div', class_='body flexposts')
        if not flexposts_section:
            print(f'   No se encontró sección .body.flexposts en este bloque')
            continue
        
        # Buscar elementos de noticias
        news_items = flexposts_section.find_all('div', class_='flexposts__item')
        # Filtrar comentarios
        news_items = [item for item in news_items if 'comment' not in item.get('class', [])]
        
        print(f'   {len(news_items)} elementos encontrados')
        
        # Procesar cada elemento
        for item in news_items:
            # Verificar que sea una noticia real
            news_link_element = item.find('a', class_='flexposts__title')
            if not news_link_element:
                continue
            
            href = news_link_element.get('href', '')
            # Excluir enlaces a comentarios
            if '#post' in href:
                continue
            
            title = news_link_element.get_text(strip=True)
            
            # Extraer información adicional
            time_element = item.find('div', class_='flexposts__time')
            time_text = time_element.get_text(strip=True) if time_element else 'N/A'
            
            impact_element = item.find('div', class_='flexposts__storyimpact')
            impact = 'none'
            if impact_element:
                classes = impact_element.get('class', [])
                if 'flexposts__storyimpact--high' in classes:
                    impact = 'high'
                elif 'flexposts__storyimpact--medium' in classes:
                    impact = 'medium'
                elif 'flexposts__storyimpact--low' in classes:
                    impact = 'low'
            
            source_element = item.find('a', class_='flexposts__caption')
            source = source_element.get_text(strip=True) if source_element else 'N/A'
            
            # Crear objeto de noticia
            news_info = {
                'blockTitle': block_title,
                'title': title,
                'href': href,
                'time': time_text,
                'impact': impact,
                'source': source,
                'fullUrl': href if href.startswith('http') else f'https://www.forexfactory.com{href}',
                'timestamp': datetime.now().isoformat()
            }
            
            all_news_links.append(news_info)
            
            # Mostrar en consola (solo algunas para no saturar)
            if len(all_news_links) <= 20:
                impact_icon = '🔴' if impact == 'high' else '🟠' if impact == 'medium' else '🟡' if impact == 'low' else '⚪'
                print(f'   {len(all_news_links)}. {impact_icon} {title[:50]}...')
    
    print(f'\n=== RESUMEN DE FILTRADO ===')
    print(f'Bloques totales: {len(all_news_blocks)}')
    print(f'Bloques excluidos: {excluded_count}')
    print(f'Noticias reales encontradas: {len(all_news_links)}')
    
    return all_news_links

def scrape_forex_news_selenium():
    """
    Extrae noticias usando Selenium para evitar bloqueos
    """
    # Configurar Chrome en modo headless
    chrome_options = Options()
    # chrome_options.add_argument('--headless')  # Ejecutar sin interfaz gráfica
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    chrome_options.add_argument('--disable-blink-features=AutomationControlled')
    chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
    chrome_options.add_experimental_option('useAutomationExtension', False)
    chrome_options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
    
    driver = None
    noticias = []
    
    try:
        driver = webdriver.Chrome(options=chrome_options)
        driver.get('https://www.forexfactory.com/news/1375459-ig-acquires-mica-license-as-revenues-hit-3076m')
        time.sleep(25)
        # Esperar a que cargue el contenido
        WebDriverWait(driver, 10).until(
            EC.presence_of_all_elements_located((By.CLASS_NAME, 'flexposts__item'))
        )
        
        
        
        # Obtener el HTML de la página
        html = driver.page_source
        
        # Extraer noticias
        noticias = extract_real_news_links(html)
        
        # Retornar solo los href
        hrefs = [noticia['href'] for noticia in noticias]
        
        return hrefs
        
    except Exception as e:
        print(f"Error en scrape_forex_news_selenium: {e}")
        return []
    finally:
        if driver:
            driver.quit()

# Ejecutar el scraper
if __name__ == "__main__":
    hrefs = scrape_forex_news_selenium()
    print(f"\n=== RESULTADOS FINALES ===")
    print(f"Total de href extraídos: {len(hrefs)}")
    for i, href in enumerate(hrefs, 1):
        print(f"{i}. {href}")
#pip install selenium webdriver-manager deep-translator beautifulsoup4
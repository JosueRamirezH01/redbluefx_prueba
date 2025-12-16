"""
Extractor automático de enlaces de Forex Factory usando Playwright
Más moderno y confiable que Selenium
"""

import asyncio
from playwright.async_api import async_playwright
import json

async def extract_forex_links(url, show_category=False):
    """
    Extrae enlaces de noticias usando Playwright
    Retorna un diccionario con enlaces organizados por categoría
    """
    async with async_playwright() as p:
        # Lanzar navegador
        browser = await p.chromium.launch(
            headless=True,  # Cambiar a False para ver el navegador
            args=['--no-sandbox', '--disable-dev-shm-usage']
        )
        
        # Crear contexto con user agent
        context = await browser.new_context(
            user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        )
        
        page = await context.new_page()
        
        try:
            print(f"🌐 Accediendo a: {url}")
            await page.goto(url, wait_until='domcontentloaded', timeout=30000)
            
            print("⏳ Esperando contenido...")
            await page.wait_for_selector('.flexposts__item', timeout=10000)
            await asyncio.sleep(1)
            
            # Inyectar script de extracción directamente
            print("📝 Ejecutando extracción...")
            categories_data = await page.evaluate("""
                () => {
                    const allNewsBlocks = document.querySelectorAll('.flexBox.news');
                    const allLinks = [];
                    const seenHrefs = new Set();
                    
                    allNewsBlocks.forEach((block) => {
                        const titleElement = block.querySelector('.flexTitle span');
                        const blockTitle = titleElement ? titleElement.textContent.trim() : 'Sin título';
                        
                        // Excluir secciones
                        if (blockTitle.includes('Latest Liked') || 
                            blockTitle.includes('Comments') ||
                            blockTitle.includes('Commented')) {
                            return;
                        }
                        
                        const flexpostsSection = block.querySelector('.body.flexposts');
                        if (!flexpostsSection) return;
                        
                        const newsItems = flexpostsSection.querySelectorAll('.flexposts__item:not(.comment)');
                        
                        newsItems.forEach(item => {
                            const newsLinkElement = item.querySelector('.flexposts__title a');
                            if (!newsLinkElement) return;
                            
                            const href = newsLinkElement.getAttribute('href');
                            if (href.includes('#post')) return;
                            
                            if (!seenHrefs.has(href)) {
                                seenHrefs.add(href);
                                const title = newsLinkElement.textContent.trim();
                                allLinks.push({
                                    href: href,
                                    title: title
                                });
                            }
                        });
                    });
                    
                    return allLinks;
                }
            """)
            print(json.dumps(categories_data))
        except Exception  as e:
            print("Error al extraer datos", e)

        

async def main():
    """Función principal"""
    FOREX_URL = "https://www.forexfactory.com/news"
    
    # Extraer enlaces
    links = await extract_forex_links(FOREX_URL, show_category=True)
    

if __name__ == "__main__":
    asyncio.run(main())
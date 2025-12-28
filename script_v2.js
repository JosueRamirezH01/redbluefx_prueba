// forex_noticias_v2.js - Versión simplificada solo para mostrar href

// Función para extraer SOLO enlaces de noticias reales (excluir comentarios/likes)
function extractRealNewsLinks(html) {
    const parser = new DOMParser();
    const doc = parser.parseFromString(html, 'text/html');
    
    // Buscar TODOS los elementos con la clase 'body flexposts'
    const allFlexposts = doc.querySelectorAll('.body.flexposts');
    
    if (!allFlexposts || allFlexposts.length === 0) {
        console.log('No se encontraron secciones de noticias');
        return [];
    }
    
    console.log(`Se encontraron ${allFlexposts.length} secciones .body.flexposts\n`);
    
    const allNewsLinks = [];
    
    // Iterar sobre cada sección
    allFlexposts.forEach((flexpostsSection, sectionIndex) => {
        // Buscar el título de la sección padre
        const sectionTitleElement = flexpostsSection.closest('.flexBox')?.querySelector('.flexTitle span');
        const sectionTitle = sectionTitleElement ? sectionTitleElement.textContent.trim() : '';
        
        // Identificar y excluir secciones de comentarios/likes
        if (sectionTitle.includes('Latest Liked') || 
            sectionTitle.includes('liked') ||
            sectionTitle.includes('Comments') ||
            sectionTitle.includes('Commented')) {
            return; // Saltar esta sección
        }
        
        // Buscar todos los elementos de noticias
        const allItems = flexpostsSection.querySelectorAll('.flexposts__item');
        
        // Procesar cada elemento
        allItems.forEach((item) => {
            // Verificar si es un comentario
            if (item.classList.contains('comment')) {
                return;
            }
            
            // Buscar enlace de noticia
            const newsLinkElement = item.querySelector('.flexposts__title a');
            
            if (!newsLinkElement) {
                return;
            }
            
            const href = newsLinkElement.getAttribute('href');
            
            // Excluir enlaces a comentarios (#post)
            if (href.includes('#post')) {
                return;
            }
            
            // Solo agregar si no está duplicado
            if (!allNewsLinks.includes(href)) {
                allNewsLinks.push(href);
            }
        });
    });
    
    return allNewsLinks;
}

// Función para mostrar SOLO los href
function displayNewsHrefs() {
    console.clear();
    console.log('=== EXTRACTOR DE ENLACES FOREX FACTORY ===\n');
    
    if (typeof window !== 'undefined' && window.document) {
        const currentHtml = document.documentElement.outerHTML;
        
        if (currentHtml.length > 10000) {
            const hrefs = extractRealNewsLinks(currentHtml);
            
            console.log(`\n=== ENLACES ENCONTRADOS (${hrefs.length}) ===\n`);
            
            // Mostrar todos los href encontrados
            hrefs.forEach((href, index) => {
                console.log(`${index + 1}. ${href}`);
            });
            
            console.log(`\n=== RESUMEN ===`);
            console.log(`Total de enlaces únicos: ${hrefs.length}`);
            
            return hrefs;
        }
    }
    
    return [];
}

// Función para mostrar hrefs por categoría
function displayHrefsByCategory(html) {
    const parser = new DOMParser();
    const doc = parser.parseFromString(html, 'text/html');
    
    // Buscar TODOS los contenedores de noticias (flexBox)
    const allNewsBlocks = doc.querySelectorAll('.flexBox.news');
    
    console.log(`Secciones encontradas: ${allNewsBlocks.length}\n`);
    
    // Procesar cada bloque
    allNewsBlocks.forEach((block, blockIndex) => {
        // Obtener título del bloque
        const titleElement = block.querySelector('.flexTitle span');
        const blockTitle = titleElement ? titleElement.textContent.trim() : `Bloque ${blockIndex + 1}`;
        
        // Saltar secciones de comentarios/likes
        if (blockTitle.includes('Latest Liked') || 
            blockTitle.includes('Comments') ||
            blockTitle.includes('Commented')) {
            console.log(`❌ ${blockTitle} (EXCLUIDO)`);
            return;
        }
        
        console.log(`✅ ${blockTitle}:`);
        
        // Extraer enlaces de este bloque
        const flexpostsSection = block.querySelector('.body.flexposts');
        if (!flexpostsSection) return;
        
        const newsItems = flexpostsSection.querySelectorAll('.flexposts__item:not(.comment)');
        let hrefCount = 0;
        
        newsItems.forEach(item => {
            const newsLinkElement = item.querySelector('.flexposts__title a');
            if (!newsLinkElement) return;
            
            const href = newsLinkElement.getAttribute('href');
            // Excluir enlaces a comentarios
            if (href.includes('#post')) return;
            
            hrefCount++;
            console.log(`   ${href}`);
        });
        
        if (hrefCount === 0) {
            console.log(`   (No se encontraron enlaces)`);
        }
        console.log('');
    });
}

// Ejecutar automáticamente en navegador
if (typeof window !== 'undefined' && window.document) {
    if (document.readyState === 'complete') {
        setTimeout(() => {
            displayNewsHrefs();
            
            // Mostrar también por categoría después de 2 segundos
            setTimeout(() => {
                console.log('\n\n=== ENLACES POR CATEGORÍA ===\n');
                displayHrefsByCategory(document.documentElement.outerHTML);
            }, 2000);
        }, 1000);
    } else {
        window.addEventListener('load', () => {
            setTimeout(() => {
                displayNewsHrefs();
                
                setTimeout(() => {
                    console.log('\n\n=== ENLACES POR CATEGORÍA ===\n');
                    displayHrefsByCategory(document.documentElement.outerHTML);
                }, 2000);
            }, 1000);
        });
    }
}

// Exportar funciones
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        extractRealNewsLinks,
        displayNewsHrefs,
        displayHrefsByCategory
    };
}
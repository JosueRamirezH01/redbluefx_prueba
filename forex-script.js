// forex_noticias_v2.js

// Función para extraer SOLO noticias reales (excluir comentarios/likes)
function extractRealNewsLinks(html) {
    const parser = new DOMParser();
    const doc = parser.parseFromString(html, 'text/html');
    
    // Buscar TODOS los elementos con la clase 'body flexposts'
    const allFlexposts = doc.querySelectorAll('.body.flexposts');
    
    if (!allFlexposts || allFlexposts.length === 0) {
        console.log('No se encontraron secciones de noticias');
        return [];
    }
    
    console.log(`Se encontraron ${allFlexposts.length} secciones .body.flexposts`);
    
    const allNewsLinks = [];
    let excludedSections = 0;
    
    // Iterar sobre cada sección
    allFlexposts.forEach((flexpostsSection, sectionIndex) => {
        // Verificar si esta sección es de "Latest Liked" o comentarios
        // Buscamos el título de la sección padre
        const sectionTitleElement = flexpostsSection.closest('.flexBox')?.querySelector('.flexTitle span');
        const sectionTitle = sectionTitleElement ? sectionTitleElement.textContent.trim() : '';
        
        // Identificar secciones a excluir
        const isExcludedSection = 
            sectionTitle.includes('Latest Liked') || 
            sectionTitle.includes('liked') ||
            sectionTitle.includes('Comments') ||
            sectionTitle.includes('Commented');
        
        if (isExcludedSection) {
            console.log(`❌ Sección ${sectionIndex + 1} EXCLUIDA: "${sectionTitle}"`);
            excludedSections++;
            return; // Saltar esta sección
        }
        
        console.log(`✅ Sección ${sectionIndex + 1} INCLUIDA: "${sectionTitle}"`);
        
        // Buscar elementos de noticias REALES (no comentarios)
        const newsItems = flexpostsSection.querySelectorAll('.flexposts__item:not(.comment)');
        
        // Si no encontramos noticias normales, buscar cualquier flexposts__item
        // pero filtrar después por tipo
        const allItems = newsItems.length > 0 ? 
            newsItems : 
            flexpostsSection.querySelectorAll('.flexposts__item');
        
        console.log(`   ${allItems.length} elementos encontrados en esta sección`);
        
        // Procesar cada elemento
        allItems.forEach((item, itemIndex) => {
            // Verificar si es un comentario (tiene clase 'comment')
            if (item.classList.contains('comment')) {
                console.log(`   ⚠️ Elemento ${itemIndex + 1} excluido (es un comentario)`);
                return;
            }
            
            // Verificar si es una noticia completa (tiene enlace de noticia)
            const newsLinkElement = item.querySelector('.flexposts__title a');
            
            if (!newsLinkElement) {
                // Podría ser un comentario disfrazado
                const commentLink = item.querySelector('.flexposts__comment-titlerow a');
                if (commentLink) {
                    console.log(`   ⚠️ Elemento ${itemIndex + 1} excluido (enlace de comentario)`);
                    return;
                }
                return;
            }
            
            // Extraer información de la noticia
            const href = newsLinkElement.getAttribute('href');
            const title = newsLinkElement.textContent.trim();
            
            // Validar que sea una noticia real (no un comentario)
            // Los enlaces de comentarios suelen tener #post en la URL
            if (href.includes('#post')) {
                console.log(`   ⚠️ Elemento ${itemIndex + 1} excluido (enlace a comentario: ${href})`);
                return;
            }
            
            // Extraer información adicional
            const timeElement = item.querySelector('.flexposts__time');
            const time = timeElement ? timeElement.textContent.trim() : 'N/A';
            
            const impactElement = item.querySelector('.flexposts__storyimpact');
            let impact = 'none';
            if (impactElement) {
                if (impactElement.classList.contains('flexposts__storyimpact--high')) impact = 'high';
                else if (impactElement.classList.contains('flexposts__storyimpact--medium')) impact = 'medium';
                else if (impactElement.classList.contains('flexposts__storyimpact--low')) impact = 'low';
            }
            
            const sourceElement = item.querySelector('.flexposts__caption a');
            const source = sourceElement ? sourceElement.textContent.trim() : 'N/A';
            
            // Verificar si tiene imagen (noticias reales suelen tener)
            const hasImage = item.querySelector('.flexposts__storyimage') !== null;
            
            // Verificar si tiene preview de texto
            const hasPreview = item.querySelector('.flexposts__preview') !== null;
            
            // Crear objeto de noticia
            const newsInfo = {
                sectionIndex: sectionIndex + 1,
                sectionTitle: sectionTitle,
                position: allNewsLinks.length + 1,
                title: title,
                href: href,
                time: time,
                impact: impact,
                source: source,
                hasImage: hasImage,
                hasPreview: hasPreview,
                isRealNews: true,
                fullUrl: href.startsWith('http') ? href : `https://www.forexfactory.com${href}`,
                timestamp: new Date().toISOString()
            };
            
            allNewsLinks.push(newsInfo);
            
            // Mostrar en consola (solo algunas para no saturar)
            if (allNewsLinks.length <= 20) {
                const impactIcon = impact === 'high' ? '🔴' : 
                                 impact === 'medium' ? '🟠' : 
                                 impact === 'low' ? '🟡' : '⚪';
                console.log(`   ${allNewsLinks.length}. ${impactIcon} ${title.substring(0, 50)}...`);
            }
        });
    });
    
    console.log(`\n=== RESUMEN DE FILTRADO ===`);
    console.log(`Secciones totales: ${allFlexposts.length}`);
    console.log(`Secciones excluidas: ${excludedSections}`);
    console.log(`Noticias reales encontradas: ${allNewsLinks.length}`);
    
    return allNewsLinks;
}

// Función para extraer TODAS las noticias con información del tipo
function extractNewsWithTypeInfo(html) {
    const parser = new DOMParser();
    const doc = parser.parseFromString(html, 'text/html');
    
    // Buscar TODOS los contenedores de noticias (flexBox)
    const allNewsBlocks = doc.querySelectorAll('.flexBox.news');
    
    console.log(`Se encontraron ${allNewsBlocks.length} bloques de noticias`);
    
    const categorizedNews = {
        breakingNews: [],
        fundamentalAnalysis: [],
        technicalAnalysis: [],
        entertainmentNews: [],
        forexIndustryNews: [],
        educationalNews: [],
        otherNews: [],
        excluded: [] // Latest Liked, comentarios, etc.
    };
    
    // Mapear títulos a categorías
    const categoryMap = {
        'Breaking News': 'breakingNews',
        'Fundamental Analysis': 'fundamentalAnalysis',
        'Technical Analysis': 'technicalAnalysis',
        'Entertainment News': 'entertainmentNews',
        'Forex Industry News': 'forexIndustryNews',
        'Educational News': 'educationalNews',
        'Latest Stories': 'otherNews',
        'Hot Stories': 'otherNews'
    };
    
    allNewsBlocks.forEach((block, blockIndex) => {
        // Obtener título del bloque
        const titleElement = block.querySelector('.flexTitle span');
        const blockTitle = titleElement ? titleElement.textContent.trim() : `Bloque ${blockIndex + 1}`;
        
        // Determinar categoría
        let category = 'otherNews';
        let isExcluded = false;
        
        // Verificar si es una sección a excluir
        if (blockTitle.includes('Latest Liked') || 
            blockTitle.includes('Comments') ||
            blockTitle.includes('Commented')) {
            category = 'excluded';
            isExcluded = true;
            console.log(`❌ Bloque EXCLUIDO: "${blockTitle}"`);
        } else {
            // Buscar coincidencia en el mapeo
            for (const [key, value] of Object.entries(categoryMap)) {
                if (blockTitle.includes(key)) {
                    category = value;
                    break;
                }
            }
            console.log(`✅ Bloque "${blockTitle}" -> Categoría: ${category}`);
        }
        
        // Extraer noticias de este bloque
        const flexpostsSection = block.querySelector('.body.flexposts');
        if (!flexpostsSection) return;
        
        const newsItems = flexpostsSection.querySelectorAll('.flexposts__item:not(.comment)');
        
        newsItems.forEach(item => {
            // Verificar que sea una noticia real
            const newsLinkElement = item.querySelector('.flexposts__title a');
            if (!newsLinkElement) return;
            
            const href = newsLinkElement.getAttribute('href');
            // Excluir enlaces a comentarios
            if (href.includes('#post')) return;
            
            const title = newsLinkElement.textContent.trim();
            
            // Extraer información
            const timeElement = item.querySelector('.flexposts__time');
            const time = timeElement ? timeElement.textContent.trim() : 'N/A';
            
            const impactElement = item.querySelector('.flexposts__storyimpact');
            let impact = 'none';
            if (impactElement) {
                if (impactElement.classList.contains('flexposts__storyimpact--high')) impact = 'high';
                else if (impactElement.classList.contains('flexposts__storyimpact--medium')) impact = 'medium';
                else if (impactElement.classList.contains('flexposts__storyimpact--low')) impact = 'low';
            }
            
            const sourceElement = item.querySelector('.flexposts__caption a');
            const source = sourceElement ? sourceElement.textContent.trim() : 'N/A';
            
            const newsInfo = {
                blockTitle: blockTitle,
                title: title,
                href: href,
                time: time,
                impact: impact,
                source: source,
                fullUrl: href.startsWith('http') ? href : `https://www.forexfactory.com${href}`
            };
            
            // Agregar a la categoría correspondiente
            if (isExcluded) {
                categorizedNews.excluded.push(newsInfo);
            } else {
                categorizedNews[category].push(newsInfo);
            }
        });
    });
    
    // Calcular estadísticas
    console.log('\n=== ESTADÍSTICAS POR CATEGORÍA ===');
    Object.entries(categorizedNews).forEach(([category, newsList]) => {
        if (category !== 'excluded' || newsList.length > 0) {
            console.log(`${category}: ${newsList.length} noticias`);
        }
    });
    
    // Combinar todas las noticias (excepto excluidas)
    const allRealNews = [
        ...categorizedNews.breakingNews,
        ...categorizedNews.fundamentalAnalysis,
        ...categorizedNews.technicalAnalysis,
        ...categorizedNews.entertainmentNews,
        ...categorizedNews.forexIndustryNews,
        ...categorizedNews.educationalNews,
        ...categorizedNews.otherNews
    ];
    
    console.log(`\nTotal noticias reales: ${allRealNews.length}`);
    console.log(`Total excluidas: ${categorizedNews.excluded.length}`);
    
    return {
        categorized: categorizedNews,
        allRealNews: allRealNews,
        stats: {
            totalReal: allRealNews.length,
            totalExcluded: categorizedNews.excluded.length,
            byCategory: Object.fromEntries(
                Object.entries(categorizedNews)
                    .filter(([cat]) => cat !== 'excluded')
                    .map(([cat, list]) => [cat, list.length])
            )
        }
    };
}

// Función para mostrar noticias organizadas por categoría
function displayNewsByCategory(newsData) {
    const { categorized, allRealNews, stats } = newsData;
    
    console.log('\n📊 NOTICIAS ORGANIZADAS POR CATEGORÍA\n');
    
    // Mostrar cada categoría
    Object.entries(categorized).forEach(([category, newsList]) => {
        if (category !== 'excluded' && newsList.length > 0) {
            const categoryNames = {
                breakingNews: '📰 Breaking News',
                fundamentalAnalysis: '📈 Fundamental Analysis',
                technicalAnalysis: '📊 Technical Analysis',
                entertainmentNews: '🎬 Entertainment News',
                forexIndustryNews: '💼 Forex Industry News',
                educationalNews: '🎓 Educational News',
                otherNews: '📰 Otras Noticias'
            };
            
            console.log(`${categoryNames[category] || category}: ${newsList.length} noticias`);
            
            // Mostrar las primeras 2-3 noticias de cada categoría
            newsList.slice(0, 3).forEach((news, index) => {
                const impactIcon = news.impact === 'high' ? '🔴' : 
                                 news.impact === 'medium' ? '🟠' : 
                                 news.impact === 'low' ? '🟡' : '⚪';
                console.log(`  ${index + 1}. ${impactIcon} ${news.title.substring(0, 60)}...`);
                console.log(`     ${news.time} | ${news.source}`);
            });
            
            if (newsList.length > 3) {
                console.log(`  ... y ${newsList.length - 3} más`);
            }
            console.log('');
        }
    });
    
    // Mostrar noticias de alto impacto de todas las categorías
    const highImpactNews = allRealNews.filter(news => news.impact === 'high');
    if (highImpactNews.length > 0) {
        console.log('🚨 NOTICIAS DE ALTO IMPACTO:');
        highImpactNews.slice(0, 5).forEach((news, index) => {
            console.log(`${index + 1}. ${news.title}`);
            console.log(`   ${news.time} | ${news.source} | ${news.blockTitle}`);
            console.log(`   ${news.fullUrl}`);
        });
        console.log('');
    }
    
    // Resumen
    console.log('=== RESUMEN FINAL ===');
    console.log(`Noticias reales totales: ${stats.totalReal}`);
    console.log(`Noticias excluidas: ${stats.totalExcluded}`);
    console.log(`Noticias de alto impacto: ${highImpactNews.length}`);
}

// Función principal mejorada
function main() {
    console.clear();
    console.log('=== EXTRACTOR DE NOTICIAS FOREX FACTORY v2.2 ===\n');
    console.log('Extrayendo SOLO noticias reales (excluyendo comentarios/likes)...\n');
    
    if (typeof window !== 'undefined' && window.document) {
        const currentHtml = document.documentElement.outerHTML;
        
        if (currentHtml.length > 10000) {
            // Método 1: Extracción con filtrado simple
            console.log('--- MÉTODO 1: Extracción con filtrado ---');
            const realNews = extractRealNewsLinks(currentHtml);
            
            // Método 2: Extracción por categorías
            console.log('\n--- MÉTODO 2: Extracción por categorías ---');
            const categorizedData = extractNewsWithTypeInfo(currentHtml);
            
            // Mostrar resultados organizados
            displayNewsByCategory(categorizedData);
            
            // Devolver ambos conjuntos de resultados
            return {
                simple: realNews,
                categorized: categorizedData,
                allNews: categorizedData.allRealNews
            };
        }
    }
    
    return null;
}

// Función para probar y debug
function testNewsExtraction() {
    if (typeof window === 'undefined') return;
    
    console.clear();
    console.log('=== PRUEBA DE EXTRACCIÓN ===\n');
    
    // Listar todos los bloques de noticias
    const allBlocks = document.querySelectorAll('.flexBox.news');
    console.log(`Total bloques .flexBox.news: ${allBlocks.length}\n`);
    
    allBlocks.forEach((block, index) => {
        const titleElement = block.querySelector('.flexTitle span');
        const title = titleElement ? titleElement.textContent.trim() : `Bloque ${index + 1}`;
        
        // Contar elementos
        const flexposts = block.querySelector('.body.flexposts');
        const totalItems = flexposts ? flexposts.querySelectorAll('.flexposts__item').length : 0;
        const commentItems = flexposts ? flexposts.querySelectorAll('.flexposts__item.comment').length : 0;
        const newsItems = totalItems - commentItems;
        
        // Determinar tipo
        let type = 'Noticias';
        if (title.includes('Latest Liked') || title.includes('Comments')) {
            type = '❌ Comentarios/Likes (EXCLUIR)';
        } else if (title.includes('Breaking News')) {
            type = '📰 Breaking News';
        } else if (title.includes('Fundamental')) {
            type = '📈 Análisis Fundamental';
        } else if (title.includes('Technical')) {
            type = '📊 Análisis Técnico';
        }
        
        console.log(`${index + 1}. ${type}: "${title}"`);
        console.log(`   Total items: ${totalItems} (${newsItems} noticias, ${commentItems} comentarios)`);
        
        // Mostrar ejemplo del primer enlace
        if (flexposts) {
            const firstLink = flexposts.querySelector('.flexposts__title a');
            if (firstLink) {
                const href = firstLink.getAttribute('href');
                console.log(`   Ejemplo: ${href.includes('#post') ? '🔗 Enlace a comentario' : '📰 Enlace a noticia'}`);
            }
        }
        console.log('');
    });
}

// Ejecutar automáticamente en navegador
if (typeof window !== 'undefined' && window.document) {
    if (document.readyState === 'complete') {
        setTimeout(() => {
            main();
            // También mostrar test para referencia
            setTimeout(() => {
                console.log('\n\n=== INFORMACIÓN DE DEBUG ===');
                testNewsExtraction();
            }, 2000);
        }, 1000);
    } else {
        window.addEventListener('load', () => {
            setTimeout(() => {
                main();
                setTimeout(() => {
                    console.log('\n\n=== INFORMACIÓN DE DEBUG ===');
                    testNewsExtraction();
                }, 2000);
            }, 1000);
        });
    }
}

// Exportar funciones
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        extractRealNewsLinks,
        extractNewsWithTypeInfo,
        displayNewsByCategory,
        main,
        testNewsExtraction
    };
}
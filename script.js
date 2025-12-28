// Cargar datos del JSON
let newsData = {};

// Función para cargar los datos
async function loadNewsData() {
    try {
        const response = await fetch('alphavantage_data.json');
        newsData = await response.json();
        displayNews('all');
    } catch (error) {
        console.error('Error cargando los datos:', error);
        document.getElementById('newsGrid').innerHTML = 
            '<div class="loading">Error al cargar las noticias</div>';
    }
}

// Función para formatear la fecha (formato Alpha Vantage: 20251213T095019)
function formatDate(dateString) {
    // Convertir formato Alpha Vantage a fecha válida
    const year = dateString.substring(0, 4);
    const month = dateString.substring(4, 6);
    const day = dateString.substring(6, 8);
    const hour = dateString.substring(9, 11);
    const minute = dateString.substring(11, 13);
    
    const date = new Date(`${year}-${month}-${day}T${hour}:${minute}:00`);
    const now = new Date();
    const diffTime = Math.abs(now - date);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays === 1) {
        return 'Hace 1 día';
    } else if (diffDays < 7) {
        return `Hace ${diffDays} días`;
    } else {
        return date.toLocaleDateString('es-ES', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
    }
}

// Función para obtener el color del sentimiento
function getSentimentColor(sentiment) {
    const sentimentColors = {
        'Bullish': '#22c55e',
        'Somewhat-Bullish': '#84cc16',
        'Neutral': '#6b7280',
        'Somewhat-Bearish': '#f59e0b',
        'Bearish': '#ef4444'
    };
    return sentimentColors[sentiment] || '#6b7280';
}

// Función para formatear tickers
function formatTickers(tickers) {
    if (!tickers || tickers.length === 0) return '';
    return tickers.slice(0, 3).map(ticker => `<span class="ticker-tag">$${ticker}</span>`).join('');
}

// Función para obtener el nombre de la categoría en español
function getCategoryName(category) {
    const categoryNames = {
        'tech_stocks': 'Tech Stocks',
        'crypto': 'Crypto',
        'financial_markets': 'Mercados Financieros',
        'commodities': 'Commodities',
        'indices': 'Índices'
    };
    return categoryNames[category] || category;
}

// Función para crear una tarjeta de noticia
function createNewsCard(article, category) {
    const card = document.createElement('div');
    card.className = 'news-card';
    card.setAttribute('data-category', category);
    
    const imageUrl = article.image_url && article.image_url !== 'NULL' && article.image_url !== null 
        ? article.image_url 
        : 'https://via.placeholder.com/400x200?text=Sin+Imagen';
    const description = article.description || 'Sin descripción disponible';
    const sentiment = article.sentiment || 'Neutral';
    const sentimentScore = article.sentiment_score || 0;
    const tickers = formatTickers(article.tickers);
    const authors = article.authors && article.authors.length > 0 && article.authors[0] !== 'NULL' 
        ? article.authors[0] 
        : 'Autor desconocido';
    
    card.innerHTML = `
        <div class="category-tag">${getCategoryName(category)}</div>
        <img src="${imageUrl}" alt="${article.title}" class="news-image" 
             onerror="this.src='https://via.placeholder.com/400x200?text=Sin+Imagen'">
        <div class="news-content">
            <h3 class="news-title">${article.title}</h3>
            <p class="news-description">${description}</p>
            
            ${tickers ? `<div class="tickers-container">${tickers}</div>` : ''}
            
            <div class="sentiment-container">
                <span class="sentiment-badge" style="background-color: ${getSentimentColor(sentiment)}">
                    ${sentiment}
                </span>
                <span class="sentiment-score">${(sentimentScore * 100).toFixed(1)}%</span>
            </div>
            
            <div class="news-meta">
                <div class="meta-left">
                    <span class="news-source">${article.source}</span>
                    <span class="news-author">por ${authors}</span>
                </div>
                <span class="news-date">${formatDate(article.published_at)}</span>
            </div>
            
            <a href="${article.url}" target="_blank" class="news-link">
                Leer más
            </a>
        </div>
    `;
    
    return card;
}

// Función para mostrar las noticias
function displayNews(selectedCategory) {
    const newsGrid = document.getElementById('newsGrid');
    newsGrid.innerHTML = '';
    
    let allArticles = [];
    
    // Recopilar artículos de todas las categorías o de la seleccionada
    if (selectedCategory === 'all') {
        Object.keys(newsData).forEach(category => {
            if (Array.isArray(newsData[category])) {
                newsData[category].forEach(article => {
                    allArticles.push({ article, category });
                });
            }
        });
    } else {
        if (newsData[selectedCategory] && Array.isArray(newsData[selectedCategory])) {
            newsData[selectedCategory].forEach(article => {
                allArticles.push({ article, category: selectedCategory });
            });
        }
    }
    
    // Ordenar por fecha (más recientes primero)
    allArticles.sort((a, b) => 
        new Date(b.article.published_at) - new Date(a.article.published_at)
    );
    
    // Crear y agregar las tarjetas
    allArticles.forEach(({ article, category }, index) => {
        const card = createNewsCard(article, category);
        card.style.animationDelay = `${index * 0.1}s`;
        newsGrid.appendChild(card);
    });
    
    // Si no hay artículos
    if (allArticles.length === 0) {
        newsGrid.innerHTML = '<div class="loading">No hay noticias disponibles en esta categoría</div>';
    }
}

// Event listeners para los botones de categoría
document.addEventListener('DOMContentLoaded', function() {
    // Cargar datos iniciales
    loadNewsData();
    
    // Configurar botones de categoría
    const categoryButtons = document.querySelectorAll('.category-btn');
    
    categoryButtons.forEach(button => {
        button.addEventListener('click', function() {
            // Remover clase active de todos los botones
            categoryButtons.forEach(btn => btn.classList.remove('active'));
            
            // Agregar clase active al botón clickeado
            this.classList.add('active');
            
            // Mostrar noticias de la categoría seleccionada
            const category = this.getAttribute('data-category');
            displayNews(category);
        });
    });
});

// Función para actualizar los datos (opcional)
function refreshNews() {
    document.getElementById('newsGrid').innerHTML = '<div class="loading">Cargando noticias...</div>';
    loadNewsData();
}

// Agregar funcionalidad de búsqueda (opcional)
function searchNews(query) {
    const newsGrid = document.getElementById('newsGrid');
    newsGrid.innerHTML = '';
    
    let filteredArticles = [];
    
    Object.keys(newsData).forEach(category => {
        if (Array.isArray(newsData[category])) {
            newsData[category].forEach(article => {
                if (article.title.toLowerCase().includes(query.toLowerCase()) ||
                    article.description.toLowerCase().includes(query.toLowerCase())) {
                    filteredArticles.push({ article, category });
                }
            });
        }
    });
    
    filteredArticles.forEach(({ article, category }) => {
        const card = createNewsCard(article, category);
        newsGrid.appendChild(card);
    });
    
    if (filteredArticles.length === 0) {
        newsGrid.innerHTML = '<div class="loading">No se encontraron noticias con ese término</div>';
    }
}
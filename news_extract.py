import requests
import json
from datetime import datetime
from deep_translator import GoogleTranslator
import time

# Tu API Key de Alpha Vantage (obtén una gratis en: https://www.alphavantage.co/support/#api-key)
API_KEY = 'VI0M1JJXWO1VNE6K'
BASE_URL = 'https://www.alphavantage.co/query'

def translate_to_spanish(text):
    """
    Traduce texto de inglés a español usando Google Translate
    
    Args:
        text (str): Texto a traducir
    
    Returns:
        str: Texto traducido o texto original si hay error
    """
    if not text or text.strip() == '':
        return text
    
    try:
        translator = GoogleTranslator(source='en', target='es')
        # Google Translate tiene límite de 5000 caracteres por petición
        if len(text) > 4500:
            text = text[:4500] + "..."
        translated = translator.translate(text)
        return translated
    except Exception as e:
        print(f"⚠️ Error al traducir: {e}")
        return text

def get_news_sentiment(tickers=None, topics=None, limit=10, sort='LATEST'):
    """
    Obtiene noticias con análisis de sentimiento de Alpha Vantage
    
    Args:
        tickers (str): Símbolos separados por coma, ej: "AAPL,MSFT,GOOGL"
        topics (str): Temas: 'blockchain', 'earnings', 'ipo', 'mergers_and_acquisitions',
                     'financial_markets', 'economy_fiscal', 'economy_monetary', 
                     'economy_macro', 'energy_transportation', 'finance', 
                     'life_sciences', 'manufacturing', 'real_estate', 'retail_wholesale', 
                     'technology'
        limit (int): Cantidad de resultados (max 1000)
        sort (str): 'LATEST', 'EARLIEST', 'RELEVANCE'
    
    Returns:
        dict: Respuesta de la API con las noticias
    """
    params = {
        'function': 'NEWS_SENTIMENT',
        'apikey': API_KEY,
        'limit': limit,
        'sort': sort
    }
    
    if tickers:
        params['tickers'] = tickers
    
    if topics:
        params['topics'] = topics
    
    try:
        print(f"  📡 Llamando a Alpha Vantage API...")
        print(f"  🔗 URL: {BASE_URL}")
        print(f"  📋 Parámetros: {params}")
        
        response = requests.get(BASE_URL, params=params)
        response.raise_for_status()
        data = response.json()
        
        # DEBUG: Mostrar la estructura de la respuesta
        print(f"  📊 Claves en respuesta: {list(data.keys())}")
        
        # Verificar si hay error en la respuesta
        if 'Error Message' in data:
            print(f"  ❌ Error de API: {data['Error Message']}")
            return None
        if 'Note' in data:
            print(f"  ⚠️ Límite de API: {data['Note']}")
            return None
        if 'Information' in data:
            print(f"  ℹ️ Información: {data['Information']}")
            return None
            
        # Verificar si hay datos
        if 'feed' in data and len(data['feed']) > 0:
            print(f"  ✓ Se encontraron {len(data['feed'])} artículos")
        else:
            print(f"  ⚠️ No se encontraron artículos en la respuesta")
            print(f"  📄 Respuesta completa: {json.dumps(data, indent=2)[:500]}")
            
        return data
    except requests.exceptions.RequestException as e:
        print(f"  ❌ Error al hacer la petición: {e}")
        return None
    except json.JSONDecodeError as e:
        print(f"  ❌ Error al decodificar JSON: {e}")
        print(f"  📄 Respuesta cruda: {response.text[:500]}")
        return None

def extract_articles_data(response, translate=True, max_articles=10):
    """
    Extrae los atributos específicos de cada artículo y traduce si es necesario
    
    Args:
        response (dict): Respuesta completa de la API
        translate (bool): Si debe traducir al español
        max_articles (int): Cantidad máxima de artículos a procesar
    
    Returns:
        list: Lista de diccionarios con los datos extraídos
    """
    if not response or 'feed' not in response:
        return []
    
    # Limitar ANTES de traducir para ahorrar tiempo
    feed = response['feed'][:max_articles]
    articles = []
    total = len(feed)
    
    if translate:
        print(f"  🔄 Traduciendo {total} artículos al español...")
    
    for idx, article in enumerate(feed):
        if translate:
            print(f"    Traduciendo {idx+1}/{total}...", end='\r')
        
        # Extraer información de sentimiento
        overall_sentiment = article.get('overall_sentiment_label', 'Neutral')
        sentiment_score = float(article.get('overall_sentiment_score', 0))
        
        # Extraer tickers relacionados
        ticker_sentiment = article.get('ticker_sentiment', [])
        tickers = [t['ticker'] for t in ticker_sentiment[:5]] if ticker_sentiment else []
        
        # Extraer y traducir contenido
        title = article.get('title', '')
        summary = article.get('summary', '')
        
        if translate:
            title = translate_to_spanish(title)
            summary = translate_to_spanish(summary)
            # Pequeña pausa para no saturar el traductor
            time.sleep(0.1)
        
        article_data = {
            'title': title,
            'description': summary,
            'url': article.get('url', ''),
            'image_url': article.get('banner_image', ''),
            'source': article.get('source', ''),
            'published_at': article.get('time_published', ''),
            'sentiment': overall_sentiment,
            'sentiment_score': sentiment_score,
            'tickers': tickers,
            'topics': [t['topic'] for t in article.get('topics', [])],
            'authors': article.get('authors', [])
        }
        articles.append(article_data)
    
    if translate:
        print(f"    ✓ Traducción completada" + " "*30)
    
    return articles

def get_sentiment_emoji(sentiment):
    """Retorna emoji según el sentimiento"""
    sentiment_map = {
        'Bullish': '📈 Alcista',
        'Bearish': '📉 Bajista',
        'Neutral': '➖ Neutral',
        'Somewhat-Bullish': '📊 Algo Alcista',
        'Somewhat-Bearish': '📊 Algo Bajista'
    }
    return sentiment_map.get(sentiment, sentiment)

def print_article(article, index):
    """Imprime un artículo de forma legible"""
    print(f"\n{'='*80}")
    print(f"ARTÍCULO #{index + 1}")
    print(f"{'='*80}")
    print(f"Título: {article['title']}")
    print(f"Descripción: {article['description'][:200]}..." if len(article['description']) > 200 else f"Descripción: {article['description']}")
    print(f"Fuente: {article['source']}")
    print(f"Fecha: {article['published_at']}")
    print(f"Sentimiento: {get_sentiment_emoji(article['sentiment'])} (Score: {article['sentiment_score']:.3f})")
    if article['tickers']:
        print(f"Tickers: {', '.join(article['tickers'])}")
    if article['topics']:
        print(f"Temas: {', '.join(article['topics'][:3])}")
    print(f"URL: {article['url']}")
    print(f"Imagen: {article['image_url']}")

def save_to_json(data, filename='alphavantage_data.json'):
    """Guarda los datos en un archivo JSON"""
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"\n✅ Datos guardados en {filename}")

# ============================================================================
# EJEMPLO DE USO - 5 LLAMADAS A DIFERENTES MERCADOS
# ============================================================================

if __name__ == "__main__":
    print("🚀 Iniciando recopilación de datos de Alpha Vantage API...\n")
    print("⚠️  IMPORTANTE: ")
    print("   1. Obtén tu API key gratis en: https://www.alphavantage.co/support/#api-key")
    print("   2. Alpha Vantage tiene límite de 25 peticiones/día (gratis)")
    print("   3. Instala: pip install requests deep-translator\n")
    
    all_market_data = {}
    
    # 1. TECH STOCKS - Probar con menos tickers primero
    print("="*80)
    print("📱 1/5 - Obteniendo noticias de TECH STOCKS...")
    print("="*80)
    print("⚠️  Probando diferentes estrategias...")
    
    # Estrategia 1: Con tickers específicos
    print("\n  Estrategia 1: Con tickers AAPL,MSFT,GOOGL")
    tech_response = get_news_sentiment(
        tickers="AAPL,MSFT,GOOGL",
        limit=10
    )
    
    # Si no funciona, intentar sin tickers pero con topic
    if not tech_response or 'feed' not in tech_response or len(tech_response.get('feed', [])) == 0:
        print("\n  Estrategia 2: Solo con topic 'technology'")
        time.sleep(12)
        tech_response = get_news_sentiment(
            topics="technology",
            limit=10
        )
    
    # Si aún no funciona, intentar sin filtros
    if not tech_response or 'feed' not in tech_response or len(tech_response.get('feed', [])) == 0:
        print("\n  Estrategia 3: Sin filtros (últimas noticias generales)")
        time.sleep(12)
        tech_response = get_news_sentiment(limit=10)
    
    # Limitar a solo 10 artículos después de traducir
    tech_articles = extract_articles_data(tech_response, translate=True, max_articles=10)
    all_market_data['tech_stocks'] = tech_articles
    print(f"✓ Obtenidos {len(tech_articles)} artículos de Tech Stocks\n")
    time.sleep(12)  # Esperar 12 segundos entre llamadas (límite de 5 por minuto)
    
    # 2. CRIPTOMONEDAS
    print("="*80)
    print("₿ 2/5 - Obteniendo noticias de CRIPTOMONEDAS...")
    print("="*80)
    crypto_response = get_news_sentiment(
        topics="blockchain",
        limit=10
    )
    crypto_articles = extract_articles_data(crypto_response, translate=True, max_articles=10)
    all_market_data['crypto'] = crypto_articles
    print(f"✓ Obtenidos {len(crypto_articles)} artículos de Cripto\n")
    time.sleep(12)
    
    # 3. COMMODITIES (Oro, Petróleo, Plata)
    print("="*80)
    print("🛢️ 3/5 - Obteniendo noticias de COMMODITIES...")
    print("="*80)
    commodities_response = get_news_sentiment(
        topics="energy_transportation",
        limit=10
    )
    commodities_articles = extract_articles_data(commodities_response, translate=True, max_articles=10)
    all_market_data['commodities'] = commodities_articles
    print(f"✓ Obtenidos {len(commodities_articles)} artículos de Commodities\n")
    time.sleep(12)
    
    # 4. MERCADOS FINANCIEROS GENERALES
    print("="*80)
    print("📊 4/5 - Obteniendo noticias de MERCADOS FINANCIEROS...")
    print("="*80)
    markets_response = get_news_sentiment(
        topics="financial_markets",
        limit=10
    )
    markets_articles = extract_articles_data(markets_response, translate=True, max_articles=10)
    all_market_data['financial_markets'] = markets_articles
    print(f"✓ Obtenidos {len(markets_articles)} artículos de Mercados\n")
    time.sleep(12)
    
    # 5. ECONOMÍA Y POLÍTICAS
    print("="*80)
    print("🏛️ 5/5 - Obteniendo noticias de ECONOMÍA...")
    print("="*80)
    economy_response = get_news_sentiment(
        topics="economy_macro",
        limit=10
    )
    economy_articles = extract_articles_data(economy_response, translate=True, max_articles=10)
    all_market_data['economy'] = economy_articles
    print(f"✓ Obtenidos {len(economy_articles)} artículos de Economía\n")
    
    # MOSTRAR ALGUNOS EJEMPLOS
    print("\n" + "="*80)
    print("📰 EJEMPLOS DE ARTÍCULOS OBTENIDOS (TRADUCIDOS AL ESPAÑOL)")
    print("="*80)
    
    if tech_articles:
        print("\n🔷 TECH STOCKS - Primeros 2 artículos:")
        for i, article in enumerate(tech_articles[:2]):
            print_article(article, i)
    
    if crypto_articles:
        print("\n\n🔶 CRIPTOMONEDAS - Primer artículo:")
        if crypto_articles:
            print_article(crypto_articles[0], 0)
    
    # GUARDAR TODOS LOS DATOS EN JSON
    save_to_json(all_market_data)
    
    # RESUMEN FINAL
    print("\n" + "="*80)
    print("📈 RESUMEN DE DATOS OBTENIDOS")
    print("="*80)
    total_articles = sum(len(articles) for articles in all_market_data.values())
    
    print(f"Total de artículos recopilados: {total_articles}")
    print(f"\nPor categoría:")
    print(f"  📱 Tech Stocks: {len(all_market_data['tech_stocks'])} artículos")
    print(f"  ₿ Criptomonedas: {len(all_market_data['crypto'])} artículos")
    print(f"  🛢️ Commodities: {len(all_market_data['commodities'])} artículos")
    print(f"  📊 Mercados Financieros: {len(all_market_data['financial_markets'])} artículos")
    print(f"  🏛️ Economía: {len(all_market_data['economy'])} artículos")
    
    # Análisis de sentimiento general
    print(f"\n📊 Análisis de Sentimiento General:")
    all_articles = [a for articles in all_market_data.values() for a in articles]
    if all_articles:
        bullish = sum(1 for a in all_articles if 'Bullish' in a['sentiment'])
        bearish = sum(1 for a in all_articles if 'Bearish' in a['sentiment'])
        neutral = sum(1 for a in all_articles if a['sentiment'] == 'Neutral')
        
        print(f"  📈 Alcista: {bullish} artículos ({bullish/len(all_articles)*100:.1f}%)")
        print(f"  📉 Bajista: {bearish} artículos ({bearish/len(all_articles)*100:.1f}%)")
        print(f"  ➖ Neutral: {neutral} artículos ({neutral/len(all_articles)*100:.1f}%)")
    
    print("="*80)
    
    # ACCESO INDIVIDUAL A LOS DATOS
    print("\n💡 Ejemplo de acceso a los datos extraídos:")
    print("\nPrimer artículo de Tech Stocks:")
    if tech_articles:
        first_article = tech_articles[0]
        print(f"  - Título: {first_article['title']}")
        print(f"  - Descripción: {first_article['description'][:100]}...")
        print(f"  - URL: {first_article['url']}")
        print(f"  - Imagen: {first_article['image_url']}")
        print(f"  - Fuente: {first_article['source']}")
        print(f"  - Publicado: {first_article['published_at']}")
        print(f"  - Sentimiento: {first_article['sentiment']} ({first_article['sentiment_score']:.3f})")
        print(f"  - Tickers relacionados: {', '.join(first_article['tickers'])}")
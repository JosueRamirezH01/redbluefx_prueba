// This script is designed to be run in the browser's developer console
// on the page https://www.forexfactory.com/news

function scrapeNewsLinks() {
  const newsLinks = [];
  const elements = document.querySelectorAll('ul.body.flexposts li.flexposts__item a');

  elements.forEach(element => {
    const link = element.getAttribute('href');
    if (link && link.startsWith('/news/')) {
        // Prepend the base URL if the link is relative
        const absoluteLink = `https://www.forexfactory.com${link}`;
        if (!newsLinks.includes(absoluteLink)) {
            newsLinks.push(absoluteLink);
        }
    }
  });

  console.log(newsLinks);
  return newsLinks;
}

scrapeNewsLinks();


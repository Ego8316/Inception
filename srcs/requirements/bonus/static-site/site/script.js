const revealItems = document.querySelectorAll('.reveal');

const showItem = (item) => {
  item.classList.add('is-visible');
};

if ('IntersectionObserver' in window) {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          showItem(entry.target);
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.2 }
  );

  revealItems.forEach((item, index) => {
    item.style.transitionDelay = `${Math.min(index * 60, 360)}ms`;
    observer.observe(item);
  });
} else {
  revealItems.forEach(showItem);
}

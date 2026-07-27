/**
 * Gemini Soft Premium Creator Platform - Prototype Logic
 * Source: docs/gemini_design_opinion/design_context_2.md
 */

document.addEventListener('DOMContentLoaded', () => {
  // Goal Selection Cards Toggle (Campaign Creation Form)
  const goalCards = document.querySelectorAll('.goal-card');
  goalCards.forEach(card => {
    card.addEventListener('click', () => {
      goalCards.forEach(c => c.classList.remove('selected'));
      card.classList.add('selected');
    });
  });

  // Task Checkbox Toggle (Gamified Tasks)
  const taskChecks = document.querySelectorAll('.task-check');
  taskChecks.forEach(check => {
    check.addEventListener('click', (e) => {
      e.stopPropagation();
      check.classList.toggle('checked');
      if (check.classList.contains('checked')) {
        check.innerHTML = '✓';
      } else {
        check.innerHTML = '';
      }
    });
  });

  // Carousel Navigation Scroll
  const carouselLeft = document.querySelector('.carousel-btn-left');
  const carouselRight = document.querySelector('.carousel-btn-right');
  const carouselContainer = document.querySelector('.carousel-container');

  if (carouselLeft && carouselRight && carouselContainer) {
    carouselLeft.addEventListener('click', () => {
      carouselContainer.scrollBy({ left: -280, behavior: 'smooth' });
    });

    carouselRight.addEventListener('click', () => {
      carouselContainer.scrollBy({ left: 280, behavior: 'smooth' });
    });
  }
});

// ================= SYNCHRONIZED STUDIO 1:1 INTERACTIVE SCRIPT ================= //

document.addEventListener('DOMContentLoaded', () => {

  // ================= 1. FLUID MAGNETIC CURSOR ================= //
  const dot = document.getElementById('cursor-dot');
  const follower = document.getElementById('cursor-follower');
  const label = document.getElementById('cursor-label');

  let mouseX = window.innerWidth / 2;
  let mouseY = window.innerHeight / 2;
  let followerX = mouseX;
  let followerY = mouseY;
  let isHovered = false;

  window.addEventListener('mousemove', (e) => {
    mouseX = e.clientX;
    mouseY = e.clientY;

    dot.style.left = `${mouseX}px`;
    dot.style.top = `${mouseY}px`;

    if (!isHovered) {
      follower.style.opacity = '0.4';
    }
  });

  window.addEventListener('mouseleave', () => {
    dot.style.opacity = '0';
    follower.style.opacity = '0';
  });

  window.addEventListener('mouseenter', () => {
    dot.style.opacity = '1';
    follower.style.opacity = isHovered ? '1' : '0.4';
  });

  // Lerp Animation Loop for Smooth Follower Tracking
  function animateCursor() {
    followerX += (mouseX - followerX) * 0.15;
    followerY += (mouseY - followerY) * 0.15;

    follower.style.left = `${followerX}px`;
    follower.style.top = `${followerY}px`;

    requestAnimationFrame(animateCursor);
  }
  animateCursor();

  // Handle data-cursor hover states
  const hoverElements = document.querySelectorAll('[data-cursor], a, button, .case-card');
  hoverElements.forEach((el) => {
    el.addEventListener('mouseenter', () => {
      isHovered = true;
      const text = el.getAttribute('data-cursor') || 'VIEW';
      label.textContent = text;
      
      if (text === 'DRAG') {
        follower.classList.add('drag');
      } else {
        follower.classList.add('active');
      }
    });

    el.addEventListener('mouseleave', () => {
      isHovered = false;
      label.textContent = '';
      follower.classList.remove('active', 'drag');
      follower.style.opacity = '0.4';
    });
  });


  // ================= 2. DRAGGABLE HORIZONTAL CAROUSEL ================= //
  const slider = document.querySelector('.carousel-wrapper');
  let isDown = false;
  let startX;
  let scrollLeft;

  if (slider) {
    slider.addEventListener('mousedown', (e) => {
      isDown = true;
      slider.classList.add('active');
      startX = e.pageX - slider.offsetLeft;
      scrollLeft = slider.scrollLeft;
    });

    slider.addEventListener('mouseleave', () => {
      isDown = false;
    });

    slider.addEventListener('mouseup', () => {
      isDown = false;
    });

    slider.addEventListener('mousemove', (e) => {
      if (!isDown) return;
      e.preventDefault();
      const x = e.pageX - slider.offsetLeft;
      const walk = (x - startX) * 1.8; // Scroll speed multiplier
      slider.scrollLeft = scrollLeft - walk;
    });
  }


  // ================= 3. LIVE NYC CLOCK ================= //
  const liveTimeEl = document.getElementById('live-time');
  function updateTime() {
    if (!liveTimeEl) return;
    const now = new Date();
    const options = { timeZone: 'America/New_York', hour: '2-digit', minute: '2-digit', hour12: true };
    const timeString = new Intl.DateTimeFormat('en-US', options).format(now);
    liveTimeEl.textContent = `NEW YORK ${timeString.toUpperCase()}`;
  }
  updateTime();
  setInterval(updateTime, 30000);


  // ================= 4. GSAP ENTRANCE & SCROLL ANIMATIONS ================= //
  if (typeof gsap !== 'undefined') {
    gsap.registerPlugin(ScrollTrigger);

    // Fade in Hero Typography
    gsap.from('.editorial-headline-container h1', {
      opacity: 0,
      y: 40,
      duration: 1.2,
      ease: 'power3.out',
      delay: 0.2
    });

    // Stagger in Selected Cases
    gsap.from('.case-card', {
      scrollTrigger: {
        trigger: '#cases',
        start: 'top 80%',
      },
      opacity: 0,
      y: 50,
      stagger: 0.15,
      duration: 1,
      ease: 'power3.out'
    });
  }

});

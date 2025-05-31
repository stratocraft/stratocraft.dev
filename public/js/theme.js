// Theme toggle functionality
function toggleTheme() {
    console.log('toggleTheme called');
    const html = document.documentElement;
    const isDark = html.classList.contains('dark');
    
    console.log('Current classList:', html.classList.toString());
    console.log('Is currently dark:', isDark);
    console.log('Current localStorage.theme:', localStorage.theme);

    if (isDark) {
        html.classList.remove('dark');
        localStorage.theme = 'light';
        console.log('Switched to light mode');
        console.log('New classList:', html.classList.toString());
    } else {
        html.classList.add('dark');
        localStorage.theme = 'dark';
        console.log('Switched to dark mode');
        console.log('New classList:', html.classList.toString());
    }
    
    // Double-check the change took effect
    setTimeout(() => {
        console.log('After timeout - classList:', html.classList.toString());
        console.log('After timeout - localStorage.theme:', localStorage.theme);
    }, 100);
}

console.log('Theme script loaded');

// Wait for DOM to be fully loaded
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM content loaded');
    
    // Add event listeners for both desktop and mobile toggle buttons
    const themeToggle = document.getElementById('theme-toggle');
    const themeToggleMobile = document.getElementById('theme-toggle-mobile');
    
    console.log('Theme toggle element:', themeToggle);
    console.log('Theme toggle mobile element:', themeToggleMobile);
    
    if (themeToggle) {
        themeToggle.addEventListener('click', toggleTheme);
        console.log('Added click listener to desktop theme toggle');
    } else {
        console.log('Desktop theme toggle element not found');
    }
    
    if (themeToggleMobile) {
        themeToggleMobile.addEventListener('click', toggleTheme);
        console.log('Added click listener to mobile theme toggle');
    } else {
        console.log('Mobile theme toggle element not found');
    }

    // Smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Intersection Observer for animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    // Observe elements for animation
    document.querySelectorAll('section > div > *').forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(20px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });
});
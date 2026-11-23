import { LightningElement, api, wire } from 'lwc';
import getPortfolioData from '@salesforce/apex/PortfolioController.getPortfolioData';
import portfolioLogo from '@salesforce/resourceUrl/portfolioLogo';
const THEME_KEY = 'portfolio-theme';

export default class PortfolioApp extends LightningElement {
    @api siteName = "Khurshida' SandBox";
    @api fullName = "SK Khurshida Banu";
    @api tagline = '';
    @api bio = '';
    @api location = '';
    @api email = '';
    @api whatsappNumber = '';
    @api linkedinUrl = '';
    @api githubUrl = '';
    @api instagramUrl = '';
    @api trailheadUrl = '';
    portfolioLogo = portfolioLogo;

    isDark = true;
    data = {};
    loadError = false;
    isLoading = true;

    connectedCallback() {
        try {
            const saved = window.localStorage.getItem(THEME_KEY);
            if (saved) {
                this.isDark = saved === 'dark';
            }
        } catch (e) {
            // storage unavailable; keep default theme
        }
    }

    @wire(getPortfolioData)
    wiredData({ data, error }) {
        if (data) {
            this.data = data;
            this.loadError = false;
            this.isLoading = false;
        } else if (error) {
            this.loadError = true;
            this.isLoading = false;
        }
    }

    get themeClass() {
        return 'pf ' + (this.isDark ? 'pf-dark' : 'pf-light');
    }

    get toggleLabel() {
        return this.isDark ? 'Switch to light theme' : 'Switch to dark theme';
    }

    get toggleIcon() {
        return this.isDark ? '☀' : '☾';
    }

    get initials() {
        return (this.fullName || '')
            .split(/\s+/)
            .filter((part) => part)
            .slice(0, 2)
            .map((part) => part.charAt(0).toUpperCase())
            .join('');
    }

    get navItems() {
        return [
            { id: 'about', label: 'About' },
            { id: 'skills', label: 'Skills' },
            { id: 'projects', label: 'Projects' },
            { id: 'experience', label: 'Experience' },
            { id: 'certifications', label: 'Certifications' },
            { id: 'blog', label: 'Blog' },
            { id: 'contact', label: 'Contact' }
        ];
    }

    get whatsappHref() {
        const digits = (this.whatsappNumber || '').replace(/\D/g, '');
        return digits ? 'https://wa.me/' + digits : null;
    }

    get currentYear() {
        return new Date().getFullYear();
    }

    toggleTheme() {
        this.isDark = !this.isDark;
        try {
            window.localStorage.setItem(THEME_KEY, this.isDark ? 'dark' : 'light');
        } catch (e) {
            // storage unavailable; theme applies for this visit only
        }
    }

    handleNavClick(event) {
        event.preventDefault();
        const id = event.currentTarget.dataset.id;
        const target = this.template.querySelector('[data-section="' + id + '"]');
        if (target) {
            const reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
            target.scrollIntoView({ behavior: reduce ? 'auto' : 'smooth', block: 'start' });
        }
    }
}

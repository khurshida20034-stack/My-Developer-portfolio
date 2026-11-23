import { LightningElement, api } from 'lwc';
import { safeUrl } from 'c/portfolioUtils';
import profilePhoto from '@salesforce/resourceUrl/portfolioPhoto';

export default class PortfolioHero extends LightningElement {
    @api fullName;
    @api tagline;
    @api bio;
    @api location;
    @api email;
    @api linkedinUrl;
    @api githubUrl;
    @api instagramUrl;
    @api trailheadUrl;
    @api whatsappHref;
    profilePhoto = profilePhoto;
    

    get mailHref() {
        return this.email ? 'mailto:' + this.email : null;
    }

    get socials() {
        return [
            { key: 'linkedin', label: 'LinkedIn', href: safeUrl(this.linkedinUrl) },
            { key: 'github', label: 'GitHub', href: safeUrl(this.githubUrl) },
            { key: 'instagram', label: 'Instagram', href: safeUrl(this.instagramUrl) },
            { key: 'trailhead', label: 'Trailhead', href: safeUrl(this.trailheadUrl) }
        ].filter((item) => item.href);
    }
}

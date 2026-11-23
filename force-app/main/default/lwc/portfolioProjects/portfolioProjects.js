import { LightningElement, api } from 'lwc';
import { safeUrl } from 'c/portfolioUtils';

export default class PortfolioProjects extends LightningElement {
    @api githubUrl;
    _projects = [];

    @api
    get projects() {
        return this._projects;
    }
    set projects(value) {
        this._projects = value || [];
    }

    get hasProjects() {
        return this._projects.length > 0;
    }

    get cards() {
        return this._projects.map((project) => ({
            id: project.Id,
            title: project.Name,
            description: project.Description__c,
            featured: project.Is_Featured__c,
            tags: (project.Tech_Stack__c || '')
                .split(',')
                .map((tag) => tag.trim())
                .filter((tag) => tag)
                .map((tag) => ({ key: project.Id + tag, label: tag })),
            github: safeUrl(project.GitHub_URL__c),
            demo: safeUrl(project.Demo_URL__c)
        }));
    }

    get profileLink() {
        return safeUrl(this.githubUrl);
    }
}

import { LightningElement, api } from 'lwc';
import { safeUrl, formatDate } from 'c/portfolioUtils';

export default class PortfolioBlog extends LightningElement {
    _posts = [];
    expandedId;

    @api
    get posts() {
        return this._posts;
    }
    set posts(value) {
        this._posts = value || [];
    }

    get hasPosts() {
        return this._posts.length > 0;
    }

    get cards() {
        return this._posts.map((post) => {
            const expanded = this.expandedId === post.Id;
            return {
                id: post.Id,
                title: post.Name,
                summary: post.Summary__c,
                date: formatDate(post.Published_Date__c),
                body: post.Body__c,
                hasBody: Boolean(post.Body__c),
                externalUrl: safeUrl(post.External_URL__c),
                expanded,
                toggleLabel: expanded ? 'Show less' : 'Read more'
            };
        });
    }

    handleToggle(event) {
        const id = event.currentTarget.dataset.id;
        this.expandedId = this.expandedId === id ? undefined : id;
    }
}

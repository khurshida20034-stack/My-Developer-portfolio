import { LightningElement, api } from 'lwc';
import { formatMonth } from 'c/portfolioUtils';

export default class PortfolioExperience extends LightningElement {
    _experiences = [];

    @api
    get experiences() {
        return this._experiences;
    }
    set experiences(value) {
        this._experiences = value || [];
    }

    get hasEntries() {
        return this._experiences.length > 0;
    }

    toEntry(record) {
        const start = formatMonth(record.Start_Date__c);
        const end = record.Is_Current__c ? 'Present' : formatMonth(record.End_Date__c);
        const range = [start, end].filter((part) => part).join(' - ');
        return {
            id: record.Id,
            title: record.Name,
            organization: record.Organization__c,
            location: record.Location__c,
            range,
            description: record.Description__c
        };
    }

    get workEntries() {
        return this._experiences.filter((r) => (r.Entry_Type__c || '').toLowerCase() !== 'education').map((r) => this.toEntry(r));
    }

    get educationEntries() {
        return this._experiences.filter((r) => (r.Entry_Type__c || '').toLowerCase() === 'education').map((r) => this.toEntry(r));
    }

    get hasWork() {
        return this.workEntries.length > 0;
    }

    get hasEducation() {
        return this.educationEntries.length > 0;
    }
}

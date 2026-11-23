import { LightningElement, api } from 'lwc';

export default class PortfolioSkills extends LightningElement {
    _skills = [];

    @api
    get skills() {
        return this._skills;
    }
    set skills(value) {
        this._skills = value || [];
    }

    get hasSkills() {
        return this._skills.length > 0;
    }

    get groups() {
        const byCategory = new Map();
        this._skills.forEach((skill) => {
            const category = skill.Category__c || 'Other';
            if (!byCategory.has(category)) {
                byCategory.set(category, []);
            }
            const level = skill.Proficiency__c;
            byCategory.get(category).push({
                id: skill.Id,
                name: skill.Name,
                hasLevel: level !== null && level !== undefined,
                levelLabel: 'Proficiency ' + level + ' percent',
                barStyle: 'width:' + Math.max(0, Math.min(100, level || 0)) + '%'
            });
        });
        return Array.from(byCategory, ([category, items]) => ({ category, items }));
    }
}

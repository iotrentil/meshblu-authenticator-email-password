var keystone = require('keystone');
var Types = keystone.Field.Types;

/**
 * Route Model
 * ==========
 */

var Route = new keystone.List('Route', {
    map: { name: 'title' },
    autokey: { path: 'slug', from: 'title', unique: true },
});

Route.add(
    { heading: 'Travel' },
    {
        version: { type: Types.Select, options: '0.0.1', default: '0.0.1' },
        title: { type: String, index: true},
        from: {
            country: { type: Types.Select, options: 'KR', default: 'KR' },
  		      city: { type: Types.Select, options: 'Seoul, Busan, Jeju', default: 'Seoul', dependsOn: { 'from.country': 'South-Korea' } },
            title: {
                en: { type: Types.Select, options: 'Incheon-International-Airport, Gimpo-International-Airport, Seoul-Station', dependsOn: { 'from.city': 'Seoul' } },
                ko: { type: Types.Select, options: '인천국제공항, 김포국제공항, 서울역', dependsOn: { 'from.city': 'Seoul' } }
            }
  		   //   location_Busan: { type: Types.Select, options: 'Gimhae-International-Airport, Busan-Station', index: true, dependsOn: { 'from.city': 'Busan' }
        },
        to: {
            title: {
                en: { type: Types.Text },
                ko: { type: Types.Text }
            }
        },
        seq: { type: Types.Number },
		    travel_mode: { type: Types.Select, options: 'Driving, Walking, Bicycling, Transit' },
        transit_detail: { type: Types.Select, options: 'Subway, Bus, Taxi, Airport-Limousine', dependsOn: { travel_mode: 'Transit' }},
        time: { type: Types.Number },
        cost: { type: Types.Number }
    },
    { heading: 'Considerations' },
    {
        considerations: {
//            number: { type: Types.Number },
//            baggage: { type: Types.Select, options: 'light, moderate, heavy' },
            presence_of_child: { type: Types.Boolean },
            early_departure: { type: Types.Boolean },
            late_departure: { type: Types.Boolean },
            movement_constraint: { type: Types.Boolean },
            presence_of_child: { type: Types.Boolean },
            more_than_four_members: { type: Types.Boolean },
        },
        host_mention: { type: Types.Text }
    },
    { heading: 'Steps' },
    {
        step: {
            0: { type: String },
            1: { type: String },
            2: { type: String },
            3: { type: String },
            4: { type: String },
            5: { type: String },
            6: { type: String },
            7: { type: String },
            8: { type: String },
            9: { type: String }
        }
    },
    { heading: 'Extras' },
    {
        host_recommendation: { type: Types.Select, numeric: true, options: [{ value: 0, label: 'None' }, { value: 1, label: 'Not' }, { value: 2, label: 'So-so' }, { value: 3, label: 'Highly' }], default: 0},
//        preference: { type: Types.Select, options: 'Minimum-time, Minimun-expense, Recommended' },
        longspeech: { type: Types.Textarea, height: 150 }
    }
);

Route.schema.virtual('content.full').get(function () {
    return this.content.extended || this.content.brief;
});

Route.defaultColumns = 'title, from.title.en|20%, to.title.en|20%';
Route.register();

// Copyright 2018 Novo Nordisk Foundation Center for Biosustainability, DTU.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// This file can be replaced during build by using the `fileReplacements` array.
// `ng build ---prod` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.
import {Configuration} from './configuration';

export const environment: Configuration = {
  production: false,
  apis: {
    iam: 'http://localhost:8001',
    model: 'http://localhost:8004',
    model_storage: 'http://localhost:8005',
    bigg: 'https://api.dd-decaf.eu/bigg',
    map: 'http://localhost:8002',
    metabolic_ninja: 'http://localhost:8003',
    warehouse: 'http://localhost:8006',
    maps: 'http://localhost:8002',
    design_storage: 'http://localhost:8007',
  },
  GA: null,
  sentry: null,
  firebase: {
    api_key: 'AIzaSyApbLMKp7TprhjH75lpcmJs514uI11fEIo',
    auth_domain: 'dd-decaf-cfbf6.firebaseapp.com',
    database_url: 'https://dd-decaf-cfbf6.firebaseio.com',
    project_id: 'dd-decaf-cfbf6',
    storage_bucket: 'dd-decaf-cfbf6.appspot.com',
    sender_id: '972933293195',
  },
  trustedURLs: ['https://api-staging.dd-decaf.eu/iam', 'https://api-staging.dd-decaf.eu/mstorage', 'https://api-staging.dd-decaf.eu/mcaffeine',
  'https://api-staging.dd-decaf.eu/pathways-caffeine', 'https://api-staging.dd-decaf.eu/warehouse', 'https://api-staging.dd-decaf.eu/maps'],
};

/*
 * In development mode, to ignore zone related error stack frames such as
 * `zone.run`, `zoneDelegate.invokeTask` for easier debugging, you can
 * import the following file, but please comment it out in production mode
 * because it will have performance impact when throw error
 */
// import 'zone.js/dist/zone-error';  // Included with Angular CLI.

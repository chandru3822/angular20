<template>
  <v-container>
    <v-row class="">
      <v-col cols="12" class="">
        <div v-for="statusPage in standardStatusPages" class="mt-5">
          <a :href="statusPage.statusUrl" target="_blank">{{ statusPage.name }}</a> <br>
          {{ statusPage.description }} <br>
          <div v-if="statusPage.doStatusCheck">
            <v-chip dark color="success lighten-1" label
                    class="pa-4 mt-2"
                    v-if="statusPage.incidents.length === 0">
              ALL SYSTEMS OPERATIONAL
            </v-chip>
            <div v-else class="mt-3">
              Current Incidents:
              <v-list class="pt-0 pl-3" v-for="(item, index) in statusPage.incidents" :key="index">
                <div class="incident-container">
                  <div class="incident-border"
                       :class="{'minor': item.impact === 'minor',
                          'major': item.impact === 'major',
                         'critical': item.impact === 'critical'}"></div>
                  <div class="incident-text">
                    Name: {{ item.name }} <br>
                    Status: {{ item.status }} <br>
                    Impact: {{ item.impact }}
                  </div>
                </div>
              </v-list>
            </div>
          </div>
        </div>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import constants from '@/helpers/constants'

import {ref, onMounted} from "vue";
import axios from 'axios'

  const twilioIncidents = ref([])
  const githubIncidents = ref([])
  const useFakeData = ref(false)
  const standardStatusPages = ref([
    {
      name: 'Twilio Status',
      description: 'Used for texting Contacts and Users',
      doStatusCheck: true,
      statusUrl: `https://status.twilio.com/`,
      incidentsUrl: `https://status.twilio.com/api/v2/incidents/unresolved.json`,
      incidents: []
    },
    {
      name: 'Github Status',
      description: 'Used for building/pushing any new code to any environment',
      doStatusCheck: true,
      statusUrl: `https://www.githubstatus.com/`,
      incidentsUrl: `https://www.githubstatus.com/api/v2/incidents/unresolved.json`,
      incidents: []
    },
    {
      name: 'Genesys Status',
      description: 'Used by BR phone system and 2-way updates with Contacts',
      doStatusCheck: true,
      statusUrl: `https://status.mypurecloud.com/`,
      incidentsUrl: `https://status.mypurecloud.com/api/v2/incidents/unresolved.json`,
      incidents: []
    },
    {
      name: 'Netlify Status',
      description: 'Used to push any new frontend updates',
      doStatusCheck: true,
      statusUrl: `https://www.netlifystatus.com/`,
      incidentsUrl: `https://www.netlifystatus.com/api/v2/incidents/unresolved.json`,
      incidents: []
    },
    {
      name: 'Mapbox Status',
      description: 'Used for all geolocation requests',
      doStatusCheck: true,
      statusUrl: `https://status.mapbox.com/`,
      incidentsUrl: `https://status.mapbox.com/api/v2/incidents/unresolved.json`,
      incidents: []
    },
    {
      name: 'AWS',
      description: 'WIP, use link',
      doStatusCheck: false,
      statusUrl: `https://health.aws.amazon.com/health/home`,
      incidentsUrl: ``,
      incidents: []
    },
    {
      name: 'Marketo Status',
      description: 'WIP, use link',
      doStatusCheck: false,
      statusUrl: `https://status.adobe.com/products/503491`,
      // incidentsUrl: `https://data.status.adobe.com/adobestatus/StatusEvents?_=${moment().valueOf()}`,
      incidents: []
    }
  ])
const getStandardStatusReq = async (idx, statusPageUrl) => {
  return statusPageUrl ? axios.get(statusPageUrl, {
      headers: {
        accept: "application/json",
        'Content-Type': "application/json",
        'Access-Control-Allow-Origin': "*",
        Vary: 'Origin'
      }
    }
  ).then((resp) => {
    standardStatusPages.value[idx].incidents = resp?.data?.incidents || []
  }) : Promise.resolve()
}
onMounted(async () => {
  const requests = [standardStatusPages.value.filter(ssp => ssp.doStatusCheck).map((ssp, idx) => getStandardStatusReq(idx, ssp.incidentsUrl))]
  await Promise.all(requests).then((resp) => {
    //??
  })
})
</script>

<style scoped lang="scss">
.incident-container {
  border: solid 1px lightgray;
  display: inline-flex;
}

.incident-border {
  width: 20px;
  display: inline-block;
}

.incident-text {
  display: inline-block;
  padding: 3px 10px;
}

.minor {
  background-color: #e6d92c;
}

.major {
  background-color: var(--v-warning-base);
}

.critical {
  background-color: var(--v-error-base);
}
</style>

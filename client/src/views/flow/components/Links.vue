<template>
<v-col v-if="links.length > 0" class="pt-0">
  <v-row>
    <v-col class="text-left pa-0">
      <v-toolbar color="transparent" class="elevation-0">
        <v-toolbar-title class="headline-small">Links</v-toolbar-title>
      </v-toolbar>
      <v-row v-for="(l, index) in links" class="px-7">
        <a  :key="l.id" text target="_blank" @click="followLink(l.url)" class="text-capitalize body-medium"><v-icon color="primary" class="pr-1">mdi-link</v-icon>{{l.link}}</a>
      </v-row>
    </v-col>
  </v-row>
</v-col>
</template>

<script>
import {getRequest, followLink} from '@/helpers/helpers'

// @TODO: need to generisize this so it can be used for any object type (project, process step, contact, user, org)

export default {
  name: "Links",
  data () {
    return {
      links: [],
      linkPath: ''
    }
  },
  props: {
    projectId: Number,
    processStepId: Number,
    projectProcessStepId: Number,
    ppseId: Number,
    contactId: Number
  },
  created () {
    //leaving like this cuz i think they will add project links down the road
    this.linkPath = `/links/processStep/${this.processStepId}`
    this.fetchLinks()
  },
  computed: {},
  methods: {
    fetchLinks: async function () {
      const {data} = await getRequest(this.linkPath)
      this.links = data
    },
    followLink(url) {
      let params = {
        projectId: this.projectId,
        ppsId: this.projectProcessStepId,
        contactId: this.contactId,
        ppseId: this.ppseId
      }

      followLink(this, url, params)
    },
  }
}
</script>

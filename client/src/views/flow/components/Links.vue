<template>
<v-col v-if="links.length > 0" class="pt-0">
  <v-row>
    <v-col class="text-left py-0">
      <v-toolbar color="transparent" class="elevation-0">
        <v-toolbar-title>Links</v-toolbar-title>
      </v-toolbar>
      <v-list class="pa-0">
        <v-list-item v-for="(l, index) in links" :key="l.id" :class="{'shaded-row': index % 2}">
          <v-btn text target="_blank" :href="l.url">{{l.link}}</v-btn>
        </v-list-item>
      </v-list>
    </v-col>
  </v-row>
</v-col>
</template>

<script>
import {getRequest} from '@/helpers/helpers'

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
    projectProcessStepId: Number
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
  }
}
</script>

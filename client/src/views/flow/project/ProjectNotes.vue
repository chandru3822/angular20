<template>
  <ActivitySection
    v-if="primaryId"
    ref="activities"
    :showNotes="true"
    :path="path"
    :showActivity="false"
    :activities="activities"
    :primaryId="primaryId"
    :type="sectionType"
    class="px-2"
  />

</template>

<script>

import {getRequest} from '@/helpers/helpers'
import ActivitySection from "@/views/flow/components/ActivitySection";


export default {
  name: 'ProjectNotes',
  components: {
    ActivitySection,
  },
  props: {
    contactId: Number,
    userId: Number,
    orgId: Number,
    projectId: Number,
    objectTypeId: Number
  },
  data() {
    return {
      snackbar: {},
      activities: [],
      path: null,
      primaryId: null,
      sectionType: null
    }
  },
  created() {
    switch (this.objectTypeId) {
      case 2:
        this.primaryId = this.contactId
        this.path = `/note/getContactNotes`
        this.sectionType = `Contact`
        break
      case 3:
        this.primaryId = this.userId
        this.path = `/note/getUserNotes`
        this.sectionType = `User`
        break
      case 5:
        this.primaryId = this.orgId
        this.path = `/note/getOrgNotes`
        this.sectionType = `Org`
        break
      default:
        this.primaryId = this.projectId
        this.path = `/activity/project/${this.projectId}`
        this.sectionType = `Project`
        break
    }
    this.getActivities()
  },
  computed: {},
  methods: {
    hasDirtyActivities() {
      return this.$refs.activities.hasUnsavedActivities()
    },
    getActivities: async function () {
      if (this.primaryId && this.path) {
        try {
          const {data} = await getRequest(this.path)
          this.activities = data
        } catch {
          console.log('done gone boom')
        }
      }
    }
}
}
</script>

<style lang="scss" scoped>

</style>

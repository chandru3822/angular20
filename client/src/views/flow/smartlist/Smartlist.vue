<template>
<v-container id="smartlist-container">
  <v-row>
    <v-col cols="12">
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">Smartlist Editor</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
<!--          @TODO: background opacity isn't right. Make it match smartlists.vue -->
          <v-btn
            text
            color="primary"
            @click="smartlist.id ? updateSmartlist() : addSmartlist()"
          >
            <v-icon>save</v-icon>
            <span v-if="!IS_MOBILE">Save</span>
          </v-btn>
<!--          <v-btn text to="/smartlist/null" color="primary">-->
<!--            <v-icon>cancel</v-icon>-->
<!--            <span v-if="!IS_MOBILE">Cancel</span>-->
<!--          </v-btn>-->
        </v-toolbar-items>
      </v-toolbar>
    </v-col>

    <v-col cols="12">
      <v-card>
        <v-card-text>
          <v-row>
            <v-col cols="6">
              <v-text-field
                text
                label="Smartlist Name"
                v-model="smartlist.name"
              />
            </v-col>

            <v-col cols="6">
              <v-select
                v-model="smartlist.companyObjectTypeId"
                :items="companyObjectTypes"
                item-text="objectType"
                item-value="companyObjectTypeId"
                label="Object Type"
                placeholder="Select one..."
              />
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
  <Snackbar :snackbar="snackbar" />
</v-container>
</template>

<script>

import {IS_MOBILE, getRequest, putRequest, postRequest, logError, getSnackbar} from '@/helpers/helpers'
import Snackbar from '@/components/Snackbar'

export default {
  name: 'Smartlist',
  components: {
    Snackbar
  },
  data () {
    return {
      IS_MOBILE,
      snackbar: {},
      smartlist: {},
      companyObjectTypes: []
    }
  },
  async created () {
    this.getCompanyObjectTypes()
    if (this.$route.params?.smartlistId !== "null") {
      this.getSmartlist()
    }
  },
  methods: {
    async getSmartlist () {
      try {
        const {data} = await getRequest(`/smartlist/${this.$route.params.smartlistId}`)
        this.smartlist = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching smartlist')
      }
    },
    async getCompanyObjectTypes () {
      try {
        const {data} = await getRequest(`/customField/getCustomFieldObjectTypes`)
        this.companyObjectTypes = data.sort((a, b) => a.objectType.localeCompare(b.objectType))
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching object types')
      }
    },
    async addSmartlist () {
      try {
        await postRequest(`/smartlist`, this.smartlist)
        this.$router.back()
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error saving smartlist')
      }
    },
    async updateSmartlist () {
      try {
        await putRequest(`/smartlist/${this.smartlist.id}`, this.smartlist)
        this.$router.back()
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error saving smartlist')
      }
    }
  }
}
</script>

<style scoped lang="scss">
</style>

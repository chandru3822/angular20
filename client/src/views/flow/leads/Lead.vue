<template>
  <v-container>
    <v-row class="lead-header elevation-1">
      <v-col xs-4 class="text-left">
        <div class="lead-title">{{customer.fullName}}</div>
        <div class="lead-subtitle">
          {{customer.street1}} - {{customer.city}}, {{customer.state}}
        </div>
      </v-col>
      <v-col xs-4 class="lead-status">
        Status: {{customer.status}}
      </v-col>
      <v-col xs-4 class="lead-owner">
        <div>
          <v-avatar
              :tile="false"
              :size="40"
              color="grey lighten-4"
              class="account-img mr-2"
          >
            <img name="accountImg" src="../../../assets/user_img_placeholder.png">
          </v-avatar>
          {{customer.owner}}
        </div>
        <div>
          {{customer.ownerPosition}} | {{customer.ownerState}}
        </div>
      </v-col>
    </v-row>
    <v-row>
      <v-col xs-6 class="text-left">
        <div>
          <h3 class="mb-4">Summary</h3>
          <v-card class="pa-4">
            <v-text-field text
                          label="Phone"
                          v-model="customer.phone"></v-text-field>
            <v-text-field text
                          label="Mobile"
                          v-model="customer.mobile"></v-text-field>
            <v-text-field text
                          label="E-Mail"
                          v-model="customer.email"></v-text-field>
            <v-text-field text
                          label="Source"
                          v-model="customer.source"></v-text-field>
            <v-text-field text
                          label="Lead Source Detail"
                          v-model="customer.leadSourceDetail"></v-text-field>
          </v-card>
        </div>
        <div class="mt-4" v-for="cfg in customFieldGroups">
          <h3 class="mb-4">{{cfg.groupName}}</h3>
          <v-card class="pa-4">
            <CustomValueInput v-for="cf in cfg.customFieldValues" :readonly="true" :field="cf"></CustomValueInput>
          </v-card>
        </div>
      </v-col>
      <v-col xs-6 class="text-left">
        <h3 class="mb-4">Notes & Activity Feed</h3>
        add this as component so humes can use it too
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Snackbar from '@/components/Snackbar.vue'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

export default {
  name: 'Lead',
  components: {
    Snackbar,
    CustomValueInput
  },
  data () {
    return {
      snackbar: {},
      customer: {},
      customFieldGroups: [],
      customerId: this.$route.params.id,
      companyId: this.$store.state.user.details.companyId
    }
  },
  created () {
    this.getCustomer()
    this.getCustomFieldGroups()
  },
  methods: {
    async getCustomFieldGroups() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/api/v1/flow/${this.companyId}/customFieldValues`, { params: {
          primaryId: this.customerId,
          //  2 = customer
          objectTypeId: 2
        }})
        this.customFieldGroups = data
        console.log('randaLogger',this.customFieldGroups)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCustomer () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/api/v1/flow/${this.companyId}/customer/${this.customerId}`)
        this.customer = data

        // todo: remove these later
        this.customer.status = 'Active'
        this.customer.owner = 'Riley Burgess'
        this.customer.ownerPosition = 'Setter'
        this.customer.ownerState = 'Oregon'
        this.customer.source = 'Another Source'
        this.customer.leadSourceDetail = 'Setter Gen'
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Customer')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
  .lead-header {
    background-color: white;
  }
  .lead-title {
    font-size: 30px;
  }
  .lead-subtitle {
    font-size: 20px;
  }
  .lead-status {
    font-size: 20px;
    display: flex;
    align-items: flex-end;
    text-align: left;
  }
  .lead-owner {
    font-size: 18px;
    /*display: flex;*/
    /*align-items: flex-end;*/
    text-align: right;
  }
</style>


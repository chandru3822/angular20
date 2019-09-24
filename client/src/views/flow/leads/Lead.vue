<template>
  <v-container>
    <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
    <v-row class="lead-header elevation-1">
      <v-col xs-8 class="text-left">
        <div class="lead-title">{{customer.fullName}}</div>
        <div class="lead-subtitle">
          {{customer.street1}} - {{customer.city}}, {{customer.state}}
        </div>
      </v-col>
      <v-col xs-4 class="lead-owner">
        <div v-if="!changeOwner">
          <div v-if="customer.owner">
            <v-avatar
                :tile="false"
                :size="40"
                color="grey lighten-4"
                class="account-img mr-2"
            >
              <img name="accountImg" src="../../../assets/user_img_placeholder.png">
            </v-avatar>
            {{customer.owner.fullName}}<br/>
            {{customer.owner.position}}
          </div>
        </div>
        <div v-if="changeOwner">
          <v-autocomplete v-model="customer.owner"
                    :items="owners"
                    label="Select Owner"
                    item-text="fullName"
                    return-object
                    autocomplete="new-password"
                    @change="updateOwner"
          >
          </v-autocomplete>
        </div>
        <v-btn text small class="change-owner-button" @click="changeOwner = !changeOwner">
          <span v-if="changeOwner">cancel</span>
          <span v-else-if="customer.owner && customer.owner.userId">change</span>
          <span v-else>add owner</span>
        </v-btn>
      </v-col>
    </v-row>
    <v-row>
      <v-col xs-6 class="text-left">
        <div>
          <v-toolbar color="transparent" class="elevation-0">
            <v-toolbar-title>Summary</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <v-btn text @click="saveLead">Save</v-btn>
            </v-toolbar-items>
          </v-toolbar>
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
                          label="Created Date"
                          v-model="customer.dateCreated"></v-text-field>
          </v-card>
        </div>
        <div class="mt-4" v-for="cfg in customFieldGroups">
          <v-toolbar color="transparent" class="elevation-0">
            <v-toolbar-title>{{cfg.groupName}}</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
<!--              <v-btn text @click="saveLead">Save</v-btn>-->
            </v-toolbar-items>
          </v-toolbar>
          <v-card class="pa-4">
            <CustomValueInput v-for="cf in cfg.customFieldValues" :readonly="false" :field="cf"></CustomValueInput>
          </v-card>
        </div>
      </v-col>
      <v-col xs-6 class="text-left">
        <NotesAndActivity :showNotes="true" :showActivity="false"
                          :notes="notes" :primaryId="parseInt(customerId)"
                          type="Customer"
        ></NotesAndActivity>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Snackbar from '@/components/Snackbar.vue'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import NotesAndActivity from '@/views/flow/components/NotesAndActivity.vue'
import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

export default {
  name: 'Lead',
  components: {
    Snackbar,
    CustomValueInput,
    NotesAndActivity
  },
  data () {
    return {
      breadcrumbs: [
        {
          text: 'Back',
          disabled: false,
          exact: true,
          to: `/leads`
        },
      ],
      snackbar: {},
      customer: {},
      customFieldGroups: [],
      notes: [],
      owners: [],
      customerId: this.$route.params.id,
      companyId: this.$store.state.user.details.companyId,
      changeOwner: false
    }
  },
  created () {
    this.getCustomer()
    this.getOwners()
    this.getCustomFieldGroups()
    this.getNotes()
  },
  methods: {
    async saveLead() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.customer.customFieldGroups = this.customFieldGroups
      try {
        const {data} = await postRequest(`/customer`, this.customer)
        this.$router.push({name: 'lead', params: {id: data.id}})
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Lead')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCustomFieldGroups() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/customFieldValues/customer`, { params: {
          primaryId: this.customerId,
          //  2 = customer
          objectTypeId: 2
        }})
        this.customFieldGroups = data
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
        const {data} = await getRequest(`/customer/${this.customerId}`)
        this.customer = data

        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Customer')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getOwners () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/customer/owners`)
        this.owners = data

        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Owners')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getNotes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/note/getCustomerNotes`, { params: {
            primaryId: this.customerId
          }})
        this.notes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateOwner() {
      this.changeOwner = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await putRequest(`/customer/${this.customer.id}/updateOwner`, this.customer.owner)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Owner')
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
  .change-owner-button {
    text-decoration: underline;
    text-transform: lowercase;
  }
</style>


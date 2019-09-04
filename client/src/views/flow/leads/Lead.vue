<template>
  <v-container>
    <v-row class="lead-header elevation-1">
      <v-col xs-4 class="text-left">
        <div class="lead-title">{{customer.fullName}}</div>
        <div class="lead-subtitle">{{customer.street1}}</div>
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
            <v-text-field v-for="cf in cfg.customFields"
                text
                label="Phone"
                v-model="cf.fieldValue"></v-text-field>
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
import Snackbar from '@/components/Snackbar.vue'
import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

export default {
  name: 'Lead',
  components: {
    Snackbar
  },
  data () {
    return {
      snackbar: {},
      customer: {},
      customFieldGroups: []
    }
  },
  created () {
    this.getCustomer()
    this.getCustomFieldGroups()
  },
  methods: {
    async getCustomFieldGroups() {
      this.customFieldGroups = [
        {
          id: 1,
          groupName: 'Customer Group Here',
          customFields: [
            {
              id: 1,
              fieldName: 'Application Date',
              fieldValue: '2018-10-18'
            }
          ]
        },
        {
          id: 2,
          groupName: 'Another Group Here',
          customFields: [
            {
              id: 1,
              fieldName: 'My field name',
              fieldValue: 'a value'
            }
          ]
        }
      ]
    },
    async getCustomer () {
      this.customer = {
        firstName: 'Joe',
        lastName: 'Customer',
        fullName: 'Joe Customer',
        street1: '123 Main Street',
        city: 'Denver',
        email: 'joe.customer@gmail.com',
        source: 'Another Source',
        leadSourceDetail: 'Setter Gen',
        mobile: '999-999-9999',
        phone: '999-999-9999',
        state: 'Colorado',
        status: 'Active',
        owner: 'Riley Burgess',
        ownerPosition: 'Setter',
        ownerState: 'Oregon'
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


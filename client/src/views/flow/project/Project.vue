<template>

<!-- @TODO: Move inline css to classes -->

<v-container id="project-container">
  <v-row>
    <v-col cols="12">
      <v-sheet color="#fff" class="elevation-2 pa-4 br-10">
        <v-row>

          <v-col cols="4" class="text-left">
            <h1>{{ customer.fullName}}</h1>
            <h3>{{ customer.street1 }} - {{ customer.city }}, {{ customer.state }}</h3>
          </v-col>

          <v-col cols="8">
            <v-row justify="end">
                <UserCard
                  name="Riley Burgess"
                  role="Setter"
                  location="Colorado"
                  imageUrl="https://s3.amazonaws.com/blueraven-apps/brLogo-57.png"
                  class="user-card"/>

                <UserCard
                  name="Mike Falls"
                  role="Closer"
                  location="Colorado"
                  imageUrl="https://s3.amazonaws.com/blueraven-apps/brLogo-57.png"
                  class="user-card"/>
            </v-row>
          </v-col>

        </v-row>
      </v-sheet>
    </v-col>
  </v-row>

  <router-view></router-view>

</v-container>
</template>

<script>

import {getRequest, VUE_APP_FLOW_API} from '@/helpers/helpers'
import UserCard from '@/views/flow/components/UserCard'

export default {
  name: 'Project',
  components: {
    UserCard
  },
  data () {
    return {
      companyId: this.$store.state.user.details.companyId,
      projectId: this.$route.params.projectId,
      customer: {},
    }
  },
  created () {
    this.getCustomer()
  },
  methods: {
    getCustomer: async function () {
      try {
        const{data} = await getRequest(`${VUE_APP_FLOW_API}/${this.companyId}/customer/project/${this.projectId}`)
        this.customer = data
      } catch (e) {
        console.error('*** ERROR ***', e)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
#project-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}

.user-card {
  margin-left: 10px;
  margin-right: 10px;
}
</style>


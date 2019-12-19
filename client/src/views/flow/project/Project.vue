<template>

<!-- @TODO: Move inline css to classes -->

<v-container id="project-container">
  <v-row>
    <v-col cols="12">
        <v-row class="project-header">
          <v-col cols="4" class="text-left pl-5">
            <div class="project-title">
              <router-link :to="`/lead/${customer.id}`">{{ customer.fullName}}</router-link>
            </div>
            <div class="project-subtitle">
              {{ customer.street1 }} - {{ customer.city }}, {{ customer.state }}
            </div>
          </v-col>

          <v-col cols="8" class="pb-0">
            <v-row justify="end" class="pb-0">
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
    </v-col>
  </v-row>

  <router-view></router-view>

</v-container>
</template>

<script>

import {getRequest} from '@/helpers/helpers'
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
        const{data} = await getRequest(`/customer/project/${this.projectId}`)
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

.project-header {
  border-bottom: solid 1px #EAEAF4
}
.project-title {
  font-size: 20px;
}
.project-subtitle {
  font-size: 15px;
}

.user-card {
  margin-left: 10px;
  margin-right: 10px;
}
</style>


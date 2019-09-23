<template>
  <v-row class="fill-height" align="center" justify="start">
    <v-col class="shrink" cols="12">
      orgs placeholder
    </v-col>
  </v-row>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import { getRequest, deleteRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'OrgsList',
    data () {
      return {
      }
    },
    computed: {},
    methods: {},
    async created () {}
  }
</script>

<style lang="scss" scoped>

</style>

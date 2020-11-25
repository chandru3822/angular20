<template>
  <v-container>
    <v-row>
      function details
      {{dbFunction}}
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'

  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'DbFunction',

    data() {
      return {
        constants,
        snackbar: {},
        dbFunction: {},
        functionId: parseInt(this.$route.params.id)
      }
    },
    async created () {
      this.getFunction()
    },
    methods: {
      async getFunction() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/dbFunction/${this.functionId}`)
          this.dbFunction = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Function')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>


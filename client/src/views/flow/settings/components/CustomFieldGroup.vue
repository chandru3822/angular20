<template>
  <v-flex>
    we are here objectType: {{objectTypeId}}
  </v-flex>
</template>

<script>
  import { IS_MOBILE } from '@/helpers/helpers'

  export default {
    name: 'CustomFieldGroup',
    props: {
      objectTypeId: Number
    },
    data () {
      return {
        something: 1
      }
    },
    created () {
    },
    methods: {
      doSomething () {
      },
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
  .test {
  }
</style>

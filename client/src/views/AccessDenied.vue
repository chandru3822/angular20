<template>
  <v-main>
    <v-container class="fill-height">
      <v-row align="center" justify="center">
        <v-col cols="12" sm="8">
          <v-card color="secondaryMaster" class="elevation-12 pb-5">
            <v-toolbar dark color="red">
              <v-toolbar-title>Access Denied</v-toolbar-title>
            </v-toolbar>
              <v-card-text class="login-card-text">
              You do not have access to this page. Please contact an administrator if you feel you have reached this page in error.
            </v-card-text>
            <v-card-actions class="justify-center">
              <v-btn to="/">Go to Home</v-btn>
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </v-main>
</template>

<script>


export default {
  name: 'ServerError',
  components: {
  },
  data () {
    return {
    }
  },
  created () {},
  computed: {},
  methods: {}
}
</script>

<style scoped lang="scss">

</style>

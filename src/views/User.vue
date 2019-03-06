<template>
<div>
<v-layout row wrap>
  <v-flex xs12 sm4>
    <v-card>
      <v-card-title>
        Personal
      </v-card-title>
      <v-card-text>
        <v-text-field
          label="First Name"
        ></v-text-field>
      </v-card-text>
    </v-card>
  </v-flex>
</v-layout>
</div>
</template>
<script>
import axios from 'axios'

const {VUE_APP_BASE_API} = process.env

export default {
  name: 'user',
  data () {
    return {
      user: {}
    }
  },
  computed: {

  },
  methods: {
    async fetchUser() {
       const {data} = await axios.get(`${VUE_APP_BASE_API}/users/${this.$route.params.id}`)
      this.user = data
    }
  },
  created () {
    this.fetchUser()
  }
}
</script>
<style lang="scss" scoped>

</style>

<template>
  <v-container id="customer-container">

    <v-layout>
      <v-flex xs12>
        <v-card>
          <v-card-text>
            <v-layout justify-space-between>
              <v-layout column align-start>
                <h1>Joe Customer</h1>
                <h3>123 main Street - Denver, CO</h3>
              </v-layout>
              <v-layout>
                <v-card>
                  <v-card-text>test</v-card-text>
                </v-card>
              </v-layout>
            </v-layout>
          </v-card-text>
        </v-card>
      </v-flex>
    </v-layout>

    <v-layout wrap>
      <v-flex xs6>
        <v-layout wrap row justify-start>
          <v-flex xs12><h3 style="text-align: left">Summary</h3></v-flex>
          <v-flex xs12>
            <v-card>
              <v-card-text>Originator</v-card-text>
            </v-card>
          </v-flex>
        </v-layout>
      </v-flex>
    </v-layout>
  </v-container>
</template>

<script>
  //@TODO: The customer name is fluid and will probably change
  export default {
    name: 'Customer',
    data () {
      return {}
    }
  }
</script>

<style lang="scss" scoped>
  #customer-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }
</style>


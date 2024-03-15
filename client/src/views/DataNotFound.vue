<template>
  <v-main>
    <v-container class="fill-height">
      <v-row align="center" justify="center">
        <v-col cols="12" sm="8">
          <v-card color="white" class="elevation-12 pb-5">
            <v-toolbar dark color="error">
              <v-toolbar-title>Data Not Found</v-toolbar-title>
            </v-toolbar>
              <v-card-text class="login-card-text default-text-color">
              The data you are looking for could not be found.
            </v-card-text>
            <v-card-actions class="justify-center">
              <AlbatrossButton
                  color="primary"
                  to="/"
                  text="Click Here to Return"
              ></AlbatrossButton>
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </v-main>
</template>

<script setup>
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"

</script>

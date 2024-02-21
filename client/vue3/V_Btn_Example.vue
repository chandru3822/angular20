<template>
  <div>
    <AlbatrossButton
        id="my-button-id"
        to="/settings/functions"
        variant="text"
        text="Add New"
        color="pink"
        :loading="false"
        :disabled="false"
        icon="add"
        :show-alternate="addNew"
        alternate-icon="cancel"
        alternate-text="cancel"
        size="small"
        :hide-text-on-mobile="true"
        :capitalize="true"
        :lower-case="false"
        custom-classes="class-a class-b"
        btn-type="button"
        @click="myFunction()"
    >
      <template v-slot:default>
        <div>
          <v-icon>add</v-icon>
          This will override the default slot
        </div>
      </template>

    </AlbatrossButton>

<!--    a menu opening example-->
<!--    NOTE: .native is required when using the button as an activator -->
    <v-menu v-model="showMenu" transition="scale-transition" offset-y
            min-width="290px" :close-on-content-click="false">
      <template v-slot:activator="{ on: { click } }">
        <AlbatrossButton @click.native="click" text="Open Menu">

        </AlbatrossButton>
      </template>
      <v-card>
        <v-card-text>
          my menu here
        </v-card-text>
      </v-card>
    </v-menu>

  </div>
</template>

<script setup>
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"
import {ref} from 'vue'

const showMenu = ref(false)
const addNew = ref(false)

// Note: cannot actually use `to` and `@click` in the same button

const myFunction = () => {
  addNew.value = !addNew.value

  //other options for @click:
  // @click="myFunction()"
  // @click="() => { stuff }"
  // @click="addNew = !addNew"
  // @click="[addNew = !addNew, selectedItem = {}]"
}

</script>

<style lang="scss">

</style>

<style scoped lang="scss">

</style>

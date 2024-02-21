<template>
  <div>
    <AlbatrossButton
        id="my-button-id"
        to="/settings/functions"
        variant="text"
        text="Add New"
        color="pink"
        :loading="false"
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

  </div>
</template>

<script setup>
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"
import {ref} from 'vue'

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

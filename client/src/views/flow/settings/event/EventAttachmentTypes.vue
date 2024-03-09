<template>
  <v-container class="custom-field-group-container">
    <ObjectTypeAttachments object-type-value="event" :primary-id="primaryId"
                           :show-uploadable="true"
                           :show-linkable="true"></ObjectTypeAttachments>
  </v-container>
</template>

<script setup>
import ObjectTypeAttachments from "@/views/flow/settings/objectType/ObjectTypeAttachments";
import {ref, getCurrentInstance} from "vue";
const vueInstance = getCurrentInstance().proxy
import {useRoute} from "vue-router/composables"
const route = useRoute()

const primaryId = ref(parseInt(route.params.id))

</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
</style>

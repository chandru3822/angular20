<template>
  <v-container class="pt-0">
    <ObjectTypeAttachment object-type-value="event" :primary-key="eventId"></ObjectTypeAttachment>
  </v-container>
</template>

<script setup>
import ObjectTypeAttachment from "@/views/flow/settings/objectType/ObjectTypeAttachment";
import {ref,getCurrentInstance} from "vue";
const vueInstance = getCurrentInstance().proxy
const route = vueInstance.$route
const eventId = ref(parseInt(route.params.id))
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

</style>

<template>
  <v-container class="custom-field-group-container">
    <ObjectTypeAttachments object-type-value="project" :show-read-only="true"
    :show-uploadable="true" :show-linkable="true" :show-focused="true"></ObjectTypeAttachments>
  </v-container>
</template>

<script setup>
import ObjectTypeAttachments from "@/views/flow/settings/objectType/ObjectTypeAttachments";

</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
</style>

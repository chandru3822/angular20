<template>
  <v-container class="pt-0">
    <ObjectTypeAttachment object-type-value="project" :show-read-only="true"></ObjectTypeAttachment>
  </v-container>
</template>

<script>
import ObjectTypeAttachment from "@/views/flow/settings/objectType/ObjectTypeAttachment";

export default {
  name: 'ProjectAttachmentType',
  components: {
    ObjectTypeAttachment
  },
  data () {
    return {}
  },
  watch: {},
  methods: {}
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

</style>

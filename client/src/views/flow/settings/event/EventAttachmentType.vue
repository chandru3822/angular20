<template>
  <v-container class="pt-0">
    <ObjectTypeAttachment object-type-value="event"></ObjectTypeAttachment>
  </v-container>
</template>

<script>
import ObjectTypeAttachment from "@/views/flow/settings/objectType/ObjectTypeAttachment";

export default {
  name: 'EventAttachmentType',
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

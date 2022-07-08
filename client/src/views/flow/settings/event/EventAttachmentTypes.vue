<template>
  <v-container class="custom-field-group-container">
    <ObjectTypeAttachments object-type-value="event" :primary-id="primaryId"></ObjectTypeAttachments>
  </v-container>
</template>

<script>
import ObjectTypeAttachments from "@/views/flow/settings/objectType/ObjectTypeAttachments";

export default {
  name: 'EventAttachments',
  components: {
    ObjectTypeAttachments
  },
  data () {
    return {
      primaryId: parseInt(this.$route.params.id)
    }
  },
  watch: {},
  created () {
  },
  methods: {
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
</style>

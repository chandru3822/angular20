<template>
  <div>
    <v-checkbox
        :label="field.fieldName"
        color="green"
        :ripple="false"
        readonly
        hide-details
        v-model="field.fieldValue"
        class="default-text-color d-inline-block"
    />
    <div v-if="field.fieldValue != null" class="d-inline-block ml-3">
      <!--        i dont think we have to handle ALL data types here. just the common ones, data view fields are pretty normalized -->
      <span v-if="field.dataTypeId === 1">{{field.fieldValue | formatDate('date', 'D MMM YYYY')}}</span>
      <span v-else-if="field.dataTypeId === 2">{{field.fieldValue | formatDate('timestamp', 'D MMM YYYY H:mm a')}}</span>
      <span v-else>{{field.fieldValue}}</span>
    </div>
  </div>
</template>

<script>

import {getRequest, getSnackbar, handleHidingGlobalLoader, logError} from '@/helpers/helpers'
import constants from "@/helpers/constants";
import SpinnerInline from '@/components/SpinnerInline'
import {AppMutations} from "@/stores/AppStore";

export default {
  name: 'StatusTrackerItem',
  components: {
    SpinnerInline
  },
  props: {
    field: Object,
  },
  data() {
    return {
      constants,
    }
  },
  created() {
  },
  computed: {},
  methods: {

  }
}
</script>

<style lang="scss" scoped>

</style>

<style lang="scss">

</style>

<template>
  <div id="status-checkbox" style="z-index: 1000">
    <v-checkbox
        :label="fieldName"
        color="success lighten-1"
        :ripple="false"
        readonly
        hide-details
        v-model="field.fieldValue"
        class="default-text-color d-inline-block body-large milestone-checkbox"
    />
<!--    <div v-if="field.fieldValue != null" class="d-inline-block ml-3 body-large">-->
<!--      &lt;!&ndash;        i dont think we have to handle ALL data types here. just the common ones, data view fields are pretty normalized &ndash;&gt;-->
<!--      <span v-if="field.dataTypeId === 1">{{field.fieldValue | formatDate('date', 'D MMM YYYY')}}</span>-->
<!--      <span v-else-if="field.dataTypeId === 2">{{field.fieldValue | formatDate('timestamp', 'D MMM YYYY H:mm a')}}</span>-->
<!--      <span v-else>{{field.fieldValue}}</span>-->
<!--    </div>-->
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
      fieldName : ""
    }
  },
  created() {
    console.log(this.field);
    if(this.field.fieldValue == null){
      this.fieldName = this.field.fieldName;
    }
    else {
      if (this.field.dataTypeId == 1) {
        this.fieldName = this.field.fieldName + ':' + this.field.fieldValue.toLocaleDateString('en-US', {
          day: 'numeric', month: 'short', year: 'numeric' //formatDate('date', 'D MMM YYYY');
        })
      } else if (this.field.dataTypeId == 2 || this.field.dataTypeId == 3) {
        this.fieldName = this.field.fieldName + ':' + new Date((this.field.fieldValue + 'Z')).toLocaleDateString('en-GB', {
          day: 'numeric', month: 'long', year: 'numeric', hour: "numeric", minute: "2-digit", hour12: true //formatDate('date', 'D MMM YYYY');
        })//formatDate('timestamp', 'D MMM YYYY H:mm a');
      } else {
        this.fieldName = this.field.fieldName + ':' + this.field.fieldValue;
      }
    }
  },
  computed: {},
  methods: {

  }
}
</script>

<style lang="scss" scoped>
.body-large{
  color: #000000 !important;
  font-family: lato !important;
  font-weight: 400 !important;
  line-height: 1.563rem !important;
  font-size: 1rem !important;
  @media (min-width: 960px) {
    line-height: 1.6;  }
}

</style>

<style lang="scss">

#status-checkbox input:hover{
  cursor: default !important;
}

#status-checkbox label:hover{
  cursor: default !important;
}

#status-checkbox:hover{
  cursor: default !important;
}

#status-checkbox .v-label{
  font-family: lato;
  font-weight: 400;
  line-height: 1.563rem;
  font-size: 1rem;
  color: #000000 !important;
}

#status-checkbox .v-input__slot:hover{
  cursor: default !important;

}
#status-checkbox :hover{
  cursor: default !important;

}

</style>

<template>
  <v-menu
    v-model="menu"
    :close-on-content-click="false"
    transition="scale-transition"
    offset-y
    max-width="290px"
    min-width="290px"
  >
    <template #activator="{on}">
      <v-text-field
        class="px-2"
        :value="value | formatDateZoneless()"
        :label="label"
        type="search"
        autocomplete="off"
        :prepend-icon="'mdi-clock-outline'"
        clear-icon="mdi-close-circle"
        :clearable="!readonly"
        :disabled="readonly"
        v-on="!readonly && on"
        @click:clear="clearInput"
        :hide-details="hideDetails"
      />
    </template>
    <v-time-picker
      v-model="localValue"
      :allowed-minutes="allowedMinutes"
      :ampm-in-title="true"
    >
      <v-spacer></v-spacer>
      <v-btn text color="primaryCustom" @click="cancel()">Cancel</v-btn>
      <v-btn text color="primaryCustom" @click="saveTime()">OK</v-btn>
    </v-time-picker>
  </v-menu>
</template>


<script>

  export default {
    name: 'ZonelessTimePickerInput',
    props: {
      value: String,
      label: String,
      hideDetails: Boolean,
      //if this is empty it shows all minutes
      allowedMinutes: Function,
      readonly: {
        type: Boolean,
        default: false
      },
    },
    data: () => ({
      date: null,
      testValue: null,
      menu: false,
    }),
    created() {
      this.init()
    },
    watch: {
      '$props.value': function () {
        if(null == this.$props.value) {
          //re-init if the field ever gets nulled out
          this.init()
        }
      }
    },
    computed: {
      //cannot edit value from parent component, need a local copy to manipulate
      localValue: {
        get: function() {
          return this.$props.value
        },
        set: function (date) {
          //this is so dumb.  if I just return date the localValue never changes. so i have to use this test value garbage
          this.testValue = date
          return date
        }
      }
    },
    methods: {
      saveTime () {
        this.$emit('input', this.testValue)
        this.menu = false
      },
      cancel () {
        this.menu = false
      },
      init () {
        this.testValue = this.$props.value
      },
      clearInput () {
        this.$emit('input', null)
      }
    }
  }
</script>

<style scoped lang="scss">
</style>

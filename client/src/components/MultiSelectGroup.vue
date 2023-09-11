<template>
  <v-card v-if="!this.contentLoading" flat :color="backgroundColor" class="square-card flex-grow-1" :class="{'full-size': fullSize, 'half-size': !fullSize}">
    <v-card-title style="min-height: 40px" class="py-0 title-medium flex-display align-center">
      <span class="select-group-title">{{title}}</span>
      <v-checkbox :disabled="!userCanEdit" type="checkbox" class="ml-3"
                  v-model="enabled" @change="checkboxChanged()"></v-checkbox>
    </v-card-title>
    <div class="button-toggle" v-if="enabled">
      <v-btn-toggle
      v-model="allowFlag"
      borderless
      mandatory
      color="blue"
      class="mr-3 mt-3"
      style="opacity: 1 !important; height: 10%;"
      id="focused-toggle"
      @change="allowChanged()"
    >
      <v-btn
             id="focused-toggle"
             class="text-capitalize fix-toggle-opacity body-medium"
             style="width: 50% !important; height: 100%"
      >
        Allow
      </v-btn>
      <v-btn
             id="focused-toggle"
             class="text-capitalize  fix-toggle-opacity body-medium"
             style="width: 50% !important; height: 100%"
      >
        Deny
      </v-btn>
    </v-btn-toggle>
    </div>
    <v-card-text>
      <v-autocomplete
        v-if="enabled"
        v-model="selected"
        :items="content"
        :loading="contentLoading"
        multiple
        clearable
        :label="textLabel"
        item-text="position"
        item-value="positionId"
        return-object
        height="35px"
        class="mr-3 mt-3"
        @change="updateSelectedChanged">
        <template v-slot:prepend-item>
          <v-list-item
            ripple
            @click="[selectedChanged= true, toggleSelectAllContent(selected)]"
          >
            <v-list-item-action>
              <v-icon>{{ icon(returnObject, 'startTimeWhiteListedPositions') }}</v-icon>
            </v-list-item-action>
            <v-list-item-title>Select All</v-list-item-title>
          </v-list-item>
          <v-divider
            class="mt-2"
          ></v-divider>
        </template>
        <template v-slot:selection="{ item, index }">
          <v-chip small
                  v-if="index === 0 && selectedContent && selectedContent.length < 2">
            <span>{{ item.position }}</span>
          </v-chip>
          <span
            v-if="index === 1 && selected && selected.length >= 2"
            class="primary--text text-caption"
          >{{ selected.length }} selected</span>
        </template>
      </v-autocomplete>
      <br v-if="userCanEdit && saveButton && !enabled"/>
      <v-btn v-if="userCanEdit && saveButton" color="primary" dark class="d-inline-block white--text mt-4"
             @click="save()">
        <v-icon class="mr-2">save</v-icon>
        {{saveButtonText || 'Save'}}
      </v-btn>
    </v-card-text>
  </v-card>

</template>

<script>
import cloneDeep from "lodash.clonedeep";

export default {
  name: "MultiSelectGroup",
  props: {
    userCanEdit: Boolean,
    returnObject: {},
    content: {},
    dropdownEnabled: Boolean,
    title: String,
    label: String,
    selectedContent: {},
    allow: Boolean,
    contentLoading: Boolean,
    backgroundColor: String,
    fullSize: {
      default: false,
      type: Boolean
    },
    alternateLabel: String,
    saveButton: {
      type: Boolean,
      default: false
    },
    saveButtonText: {

    }
  },
  data() {
    return {
      allowFlag: 0,
      enabled: this.dropdownEnabled,
      contentChanged: false,
      selected: this.selectedContent,
      textLabel: this.label
    };
  },
  mounted() {
    if(!this.allow) {
      this.allowFlag = 1;
      if (this.alternateLabel != null) {
        this.textLabel = this.alternateLabel;
      }
    }
    this.selected = this.selectedContent;
  },
  methods: {
    icon(f, fieldName) {
      if (this.selectAll(f, fieldName)) {
        return 'check_box'
      }
      if (this.selectSome(f, fieldName)) {
        return 'indeterminate_check_box'
      }
      return 'check_box_outline_blank'
    },
    selectAll() {
      return this.selected?.length === this.content?.length
    },
    selectSome(f, fieldName) {
      return f[fieldName]?.length > 0 && !this.selectAll(f)
    },
    toggleSelectAllContent() {
      this.$nextTick(() => {
        if (this.selectAll()) {
          this.selected = []
          this.updateSelectedChanged()
        } else {
          this.selected = cloneDeep(this.content)
          this.updateSelectedChanged()
        }
      })
    },
    updateSelectedChanged(){
      this.$emit('selected-changed', this.selected)
    },
    allowChanged(){
      this.switchLabel();
      this.$emit('allow-changed', this.allowFlag);
    },
    checkboxChanged(){
      this.$emit('checkbox-changed', this.enabled)
    },
    save(){
      this.$emit('save-multi-select')
    },
    switchLabel(){
      if(this.alternateLabel != null) {
        if (this.allowFlag == 0) {
          this.textLabel = this.label
        } else {
          this.textLabel = this.alternateLabel
        }
      }
    }
  }
}
</script>

<style scoped>
  .v-card__text{
    padding-top: 0px;
  }
  .button-toggle{
    padding-left: 12px;
  }
  .full-size{
    width: 100%;
  }
  .half-size{
    width: 50%;
  }
  .select-group-title {
    max-width: 60%;
  }

</style>

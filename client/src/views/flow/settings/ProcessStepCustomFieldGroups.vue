<template>
  <v-layout row wrap class="">
    <!--my value: {{ createNew }}-->
    <v-flex v-if="createNew" justify-center class="flex-display pl-3 pr-3">
      <v-card text class="text-xs-center field-card one-hunned" flat
              color="rowShadeCustom">
        Create Custom Fields Group
        <v-text-field
            label="Group Name"
            tabindex=1
            v-model="newGroup.groupName"
        ></v-text-field>
        <!--<v-radio-group v-models="newGroup.processStepCustomFieldTypeId">-->
          <!--<v-radio-->
              <!--label="Fields in this group are native to this process step"-->
              <!--value="1"></v-radio>-->
          <!--<v-radio-->
              <!--label="Fields in this group are ancillary (view only from other process steps or objects)"-->
              <!--value="2"></v-radio>-->
        <!--</v-radio-group>-->
        <!--<v-flex class="options-container" fluid-->
                <!--v-if="item.companyDataType && item.companyDataType.hasListValues">-->
          <!--<span>Selectable Options</span>-->
          <!--<draggable v-models="item.dropdownOptions"-->
                     <!--group="dropdownOptions" @start="drag=true" @end="drag=false">-->
            <!--<v-list v-for="(ddo, index) in filterBy(item.dropdownOptions, false, 'archived')"-->
                    <!--:class="{'shaded-row': item.index % 2}"-->
                    <!--:key="index">-->
              <!--<v-list-item class="grab">-->
                <!--<v-list-item-content>-->
                  <!--<v-text-field-->
                      <!--class="one-hunned"-->
                      <!--:placeholder="ddo.placeholder"-->
                      <!--v-models="ddo.name">-->
                  <!--</v-text-field>-->
                <!--</v-list-item-content>-->
                <!--<v-list-item-action>-->
                  <!--<v-icon>drag_handle</v-icon>-->
                <!--</v-list-item-action>-->
                <!--<v-list-item-action class="clickable" @click="ddo.archived = true">-->
                  <!--<v-icon>delete</v-icon>-->
                <!--</v-list-item-action>-->
              <!--</v-list-item>-->
            <!--</v-list>-->
          <!--</draggable>-->
          <!--<v-btn-->
              <!--@click="addField()">-->
            <!--Add Option-->
          <!--</v-btn>-->
        <!--</v-flex>-->
        <v-btn
            color="primary"
            class="white--text mr-2"
            :disabled="!newGroup.groupName"
            @click="$emit('update', false); saveFieldGroup()">
          Save
        </v-btn>
        <v-btn
            @click="newGroup = {}; createNew = false; $emit('update', false);">
            <!--@click="newGroup = {}; randaTest = false">-->
          Cancel
        </v-btn>
      </v-card>
    </v-flex>
    <v-container>
      <draggable v-model="customFieldGroups" v-if="customFieldGroups && customFieldGroups.length > 0"
                 group="customFieldGroups" @start="drag=true" @end="drag=false" @change="changeGroupOrder">
        <v-list>
          <v-list-group v-for="(cfg, index) in filterBy(customFieldGroups, false, 'archived')"
                  :key="index"
                  :class="{ 'shaded-row': index % 2 }">
            <template v-slot:activator>
              <v-list-item class="grab">
                <v-list-item-content>
                  <div>{{cfg.groupName}}
                    <span v-if="cfg.ancillaryCustomFieldGroupId != null">(Ancillary)</span>
                  </div>
                </v-list-item-content>
                <v-list-item-action>
                  <v-icon>drag_handle</v-icon>
                </v-list-item-action>
                <v-list-item-action class="clickable">
                  <v-icon @click="">edit</v-icon>
                </v-list-item-action>
                <v-dialog
                    v-model="cfg.deleteConfirm"
                    width="500">
                  <template v-slot:activator="{ on }">
                    <v-list-item-action class="clickable" v-on="on">
                      <v-icon>delete</v-icon>
                    </v-list-item-action>
                  </template>
                  <v-card>
                    <v-card-title
                        class="headline grey lighten-2"
                        primary-title
                    >
                      Confirm
                    </v-card-title>

                    <v-card-text>
                      Are you sure you want to delete this Custom Field Group: <strong>{{ cfg.groupName }}</strong>?
                    </v-card-text>

                    <v-divider></v-divider>

                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn
                          @click="cfg.deleteConfirm = false">
                        No
                      </v-btn>
                      <v-btn
                          color="primary"
                          text
                          @click="cfg.archived = true; deleteGroupFromStep(cfg.id)">
                        Yes
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </v-list-item>
            </template>
            <v-list-item>
              <v-list-item-content>
                <v-flex justify-center class="flex-display pl-3 pr-3" :class="{'shaded-row': index % 2}">
                  <v-container>
                    <v-radio-group v-model="newFieldType" v-if="addField">
                    <v-radio label="Native Field"
                        value="native"></v-radio>
                    <v-radio label="Ancillary Field: viewed only from other process steps or objects"
                        value="ancillary"></v-radio>
                    </v-radio-group>
                    <v-select v-if="addField && newFieldType === 'native'"
                              v-model="newField"
                              :items="availableCustomFields"
                              label="New Custom Field"
                              item-text="fieldName"
                              return-object
                              @input="assignCustomField(cfg)"
                    ></v-select>

                    <v-select v-if="addField && newFieldType === 'ancillary'"
                              v-model="parent"
                              :items="parentObjects"
                              label="Parent Object"
                              item-text="name"
                              return-object
                              @input="loadFieldsByParent(cfg)"
                    ></v-select>
                    <v-select v-if="addField && newFieldType === 'ancillary'"
                              v-model="selectedAncillaryField"
                              :items="ancillaryCustomFields"
                              label="Custom Field"
                              item-text="fieldName"
                              return-object
                              @input="assignAncillaryCustomField()"
                    ></v-select>
                    <v-btn @click="addField = !addField; fetchAvailableCustomFields(cfg.objectTypeId, cfg.id)">
                      {{addField ? 'Cancel' : 'Add Field'}}
                    </v-btn>
                  </v-container>
                </v-flex>
                <v-flex justify-center class="flex-display pl-3 pr-3" :class="{'shaded-row': index % 2}">
                  <v-container>
                    <draggable v-model="cfg.customFields" v-if="cfg.customFields && cfg.customFields.length > 0"
                               group="customFields" @start="drag=true" @end="drag=false" @change="changeFieldOrder">
                      <v-list>
                        <v-list-group v-for="(cf, index) in filterBy(cfg.customFields, false, 'archived')"
                                      :key="index"
                                      :class="{ 'shaded-row': index % 2 }">
                          <template v-slot:activator>
                            <v-list-item class="grab">
                              <v-list-item-content>
                                {{cf.fieldName}}
                              </v-list-item-content>
                              <v-list-item-action>
                                <v-icon>drag_handle</v-icon>
                              </v-list-item-action>
                              <v-dialog
                                  v-model="cf.deleteConfirm"
                                  width="500">
                                <template v-slot:activator="{ on }">
                                  <v-list-item-action class="clickable" v-on="on">
                                    <v-icon>delete</v-icon>
                                  </v-list-item-action>
                                </template>
                                <v-card>
                                  <v-card-title
                                      class="headline grey lighten-2"
                                      primary-title
                                  >
                                    Confirm
                                  </v-card-title>

                                  <v-card-text>
                                    Are you sure you want to delete <strong>{{ cf.fieldName }}</strong> from <strong>{{ cfg.groupName }}</strong>?
                                  </v-card-text>

                                  <v-divider></v-divider>

                                  <v-card-actions>
                                    <v-spacer></v-spacer>
                                    <v-btn
                                        @click="cf.deleteConfirm = false">
                                      No
                                    </v-btn>
                                    <v-btn
                                        color="primary"
                                        text
                                        @click="cf.archived = true; deleteFieldFromGroup(cf.id)">
                                      Yes
                                    </v-btn>
                                  </v-card-actions>
                                </v-card>
                              </v-dialog>
                            </v-list-item>
                          </template>
                        </v-list-group>
                      </v-list>
                    </draggable>
                  </v-container>
                </v-flex>
              </v-list-item-content>
            </v-list-item>
          </v-list-group>
        </v-list>
      </draggable>
    </v-container>
  </v-layout>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import draggable from 'vuedraggable'
  import orderBy from 'lodash.orderby'
  import {getRequest, deleteRequest, putRequest, postRequest} from '@/helpers/helpers'

  export default {
    name: 'ProcessStepCustomFieldGroups',
    mixins: [Vue2Filters.mixin],
    components: {
      draggable
    },
    props: {
      customFieldGroups: Array,
      createNew: Boolean
    },
    data() {
      return {
        newGroup: {},
        newField: {},
        newFieldType: 'native',
        addField: false,
        selectedGroupId: null,
        availableCustomFields: [],
        parent: {},
        parentObjects: [
          {id: 1, name: 'testing 1'},
          {id: 2, name: 'testing 2'},
        ],
        selectedAncillaryField: {},
        ancillaryCustomFields: [
          {id: 1, fieldName: 'will populate'},
          {id: 2, fieldName: 'with real values'},
          {id: 3, fieldName: 'later'},
        ]
      }
    },
    // watch:{
    //   createNew: function(){
    //     this.randaTest = this.createNew
    //   }
    // },
    computed: {},
    async created() {

    },
    methods: {
      async saveFieldGroup () {
        // todo: what is the best way to NOT hardcode this?
        this.newGroup.objectTypeId = 4
        this.newGroup.groupOrder = 0
        this.newGroup.processStepId = this.$route.params.id

        console.log('SAVE HERE', this.newGroup )
        const {data} = await postRequest(`/api/v1/flow/customFieldGroup/addCustomFieldGroupType`, this.newGroup)
        this.customFieldGroups.push(data)
        this.newGroup = {}
        this.createNew = false
        console.log('randaLogger',data)
      },
      changeGroupOrder () {
        console.log('changed group order')
      },
      changeFieldOrder () {
        console.log('changed field order')
      },
      async deleteGroupFromStep (groupTypeId) {
        await deleteRequest(`/api/v1/flow/customFieldGroup/deleteCustomFieldGroupType/${groupTypeId}`)
      },
      async deleteFieldFromGroup (fieldGroupId) {
        await deleteRequest(`/api/v1/flow/customFieldGroup/deleteFieldFromGroup/${fieldGroupId}`)
      },
      async fetchAvailableCustomFields (objectTypeId, groupTypeId) {
        if(this.addField) {
          const {data} = await getRequest(`/api/v1/flow/customFieldGroup/getAvailableCustomFieldsInGroup`, {
            params: {
              objectTypeId,
              groupTypeId
            }
          })
          console.log('randaLogger', data)
          this.availableCustomFields = data
        }
      },
      async assignCustomField (cfg) {
        console.log('WE SHALL SAVE')
        this.addField = false
        this.newField.fieldOrder = 0
        this.newField.customFieldGroupTypeId = cfg.id

        await postRequest(`/api/v1/flow/customFieldGroup/addFieldToGroup`, this.newField)
        cfg.customFields.push(this.newField)
        this.newField = {}
      },
      async loadFieldsByParent () {
        console.log('we will load by parent')
      },
      async assignAncillaryCustomField () {
        console.log('we will save this ANCILLARY', this.selectedAncillaryField)
      }
    }

  }
</script>

<style scoped lang="scss">

</style>

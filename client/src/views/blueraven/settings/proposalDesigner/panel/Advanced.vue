<template>
  <v-card flat>
    <v-card-title>Advanced</v-card-title>
    <v-text-field outlined dense
                  v-model="visibility"
                  label="Visibility"
                  hint="This expression must evaluate to a boolean"
                  @change="handleChange"
                  clearable
    >
      <template v-slot:append-outer>
        <v-dialog
          v-model="dialog"
          width="500"
        >
          <template v-slot:activator="{ on:dialogOn, attrs }">

            <v-fade-transition leave-absolute>
              <v-btn icon v-on="dialogOn">
                <v-tooltip
                  bottom
                >
                  <template v-slot:activator="{ on }">
                    <v-icon v-on="on" v-bind="attrs">
                      mdi-help-circle-outline
                    </v-icon>
                  </template>
                  Available variables
                </v-tooltip>
              </v-btn>
            </v-fade-transition>
          </template>

          <v-card>
            <v-card-title class="text-h5 grey lighten-2">
              Allowed Variables
            </v-card-title>

            <v-card-text>
              <ul>
                <li v-for="tag in tags">
                  {{tag.tagName}} [{{tag.tagType}}]
                </li>
              </ul>
            </v-card-text>

            <v-divider></v-divider>

            <v-card-actions>
              <v-spacer></v-spacer>
              <v-btn
                color="primary"
                text
                @click="dialog = false"
              >
                Done
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>


      </template>
    </v-text-field>
  </v-card>
</template>
<script>

import {mapState} from "vuex";

export default {
  props: {
    visibility : {
      type: String
    }
  },
  data() {
    return {
      dialog: false,
    }
  },
  computed: {
    ...mapState({
      tags: (state) => state.proposal.tags
    })
  },
  methods: {
    handleChange() {
      this.$emit('input', this.visibility)
    }
  }
}
</script>

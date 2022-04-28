export const theme = {
  title: {
    textTransform: 'uppercase'
  }, page: {
    display: 'flex', flexDirection: 'column'
  }, footer: {
    fontSize: '10px'
  }
}
//TODO: need to add an orderBy field or something
export const template = [{
  type: 'PageBlock', themeClass: 'page', cssStyle: {
    color: '#ffffff',
    backgroundImage: 'url(https://modernize.com/wp-content/uploads/2016/01/Solar-Panels-Cottage.jpg)',
    backgroundPosition: 'center center',
    backgroundSize: 'cover',
    display: 'flex'
  }, children: [{
    type: 'ContainerBlock', cssStyle: {
      flex: 1, display: 'flex', flexDirection: 'column'
    }, children: [{
      type: 'TextBlock', cssStyle: {
        fontSize: '50px',
        textTransform: 'uppercase',
        flex: 1,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center'
      }, value: {
        type: 'doc', content: [{
          type: 'paragraph', content: [{
            type: 'text', marks: [{
              type: 'bold'
            }], text: 'Blue Raven'
          }, {
            type: 'text', text: ' Solar'
          }]
        }]
      }
    }, {
      type: 'ContainerBlock', children: [{
        type: 'TextBlock', value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'mention', attrs: {
                id: 'first_name', label: null
              }, marks: [{
                type: 'bold'
              }]
            }, {
              type: 'text', marks: [{
                type: 'bold'
              }], text: ' '
            }, {
              type: 'mention', attrs: {
                id: 'last_name', label: null
              }, marks: [{
                type: 'bold'
              }]
            }, {
              type: 'text', marks: [{
                type: 'bold'
              }], text: ' '
            }, {
              type: 'hardBreak'
            }, {
              type: 'mention', attrs: {
                id: 'address', label: null
              }
            }, {
              type: 'hardBreak'
            }, {
              type: 'mention', attrs: {
                id: 'city', label: null
              }
            }, {
              type: 'text', text: ' , '
            }, {
              type: 'mention', attrs: {
                id: 'state', label: null
              }
            }, {
              type: 'text', text: ' '
            }, {
              type: 'mention', attrs: {
                id: 'postal_code', label: null
              }
            }, {
              type: 'text', text: ' '
            }]
          }]
        }
      }]
    }]
  }]
}, {
  type: 'PageBlock', themeClass: 'page', cssStyle: {
    color: '#ffffff',
    backgroundImage: 'url(https://images.unsplash.com/photo-1597084945126-11df14187d08?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2072&q=100)',
    backgroundPosition: 'center center',
    backgroundSize: 'cover'
  }, children: [{
    type: 'TextBlock', themeClass: 'title', value: {
      type: 'doc', content: [{
        type: 'heading', attrs: { level: 1 }, content: [{
          type: 'text', text: 'The Problem'
        }]
      }]
    }
  }, {
    type: 'TextBlock', cssStyle: {
      width: '75%', flex: 1
    }, value: {
      type: 'doc', content: [{
        type: 'orderedList', attrs: {
          start: 1
        }, content: [{
          type: 'listItem', content: [{
            type: 'paragraph', content: [{
              type: 'text',
              text: 'Utility companies are monopolies that have complete control over pricing and service. When was the last time a monopoly was good for you and your family?'
            }]
          }]
        }, {
          type: 'listItem', content: [{
            type: 'paragraph',

            content: [{
              type: 'text',
              text: 'Utility prices continue to increase. Since 2000, the cost of electricity in America has increased by a whopping 64%'
            }, {
              type: 'text', marks: [{
                type: 'superscript'
              }], text: '1'
            }, {
              type: 'text', text: '.'
            }]
          }]
        }, {
          type: 'listItem', content: [{
            type: 'paragraph', content: [{
              type: 'text',
              text: 'As traditional sources of energy continue to get more expensive (including coal, gas, and oil), electricity rates will continue to rise.'
            }]
          }]
        }, {
          type: 'listItem', content: [{
            type: 'paragraph', content: [{
              type: 'text',
              text: 'We cannot continue to burn things to meet our energy needs. Past solutions are simply not sustainable for future generations.'
            }]
          }]
        }]
      }]
    }
  }, {
    type: 'TextBlock', themeClass: 'footer', value: {
      type: 'doc', content: [{
        type: 'paragraph', content: [{
          type: 'text', text: '1 Statista study on residential electricity price growth between 2000 and 2021. '
        }, {
          type: 'hardBreak'
        }, {
          type: 'text',
          text: 'https://www.statista.com/statistics/201714/growth-in-us-residential-electricity-prices-since-2000/'
        }]
      }]
    }
  }]
}, {
  type: 'PageBlock', themeClass: 'page', cssStyle: {
    color: '#000000',
    backgroundImage: 'url(https://www.treehugger.com/thmb/BeCUb2ViQ1tRfc6gEuvuEtYFyBM=/735x0/GettyImages-138311438-fbb787bb389446cb9869d8d46f1a1e1c.jpg)',
    backgroundPosition: 'center center',
    backgroundSize: 'cover'
  }, children: [{
    type: 'TextBlock', themeClass: 'title', value: {
      type: 'doc', content: [{
        type: 'heading', attrs: { level: 1 }, content: [{
          type: 'text', text: 'The Solar Solution'
        }]
      }]
    }
  }, {
    type: 'TextBlock', value: {
      type: 'doc', content: [{
        type: 'paragraph', content: [{
          type: 'text',
          text: 'Enough sunlight reaches the earth in one hour to power the globe\'s energy needs for a year.'
        }, {
          type: 'text', marks: [{
            type: 'superscript'
          }], text: '1'
        }, {
          type: 'text', text: ' We just need to capture it! Rooftop solar is the solution.'
        }]
      }]
    }
  }, {
    type: 'TextBlock', cssStyle: { flex: 1 }, value: {
      type: 'doc', content: [{
        type: 'orderedList', attrs: {
          start: 1
        }, content: [{
          type: 'listItem', content: [{
            type: 'paragraph',

            content: [{
              type: 'text', text: 'Stop renting energy. Own it and build equity in your energy source instead.'
            }]
          }]
        }, {
          type: 'listItem', content: [{
            type: 'paragraph',

            content: [{
              type: 'text',
              text: 'Save money on your energy bill and build credits by contributing electricity to the grid.'
            }]
          }]
        }, {
          type: 'listItem', content: [{
            type: 'paragraph',

            content: [{
              type: 'text', text: 'Increase the value of your home.'
            }, {
              type: 'text', marks: [{
                type: 'superscript'
              }], text: '2'
            }]
          }]
        }, {
          type: 'listItem', content: [{
            type: 'paragraph', content: [{
              type: 'text',
              text: 'Eliminate the equivalent of 16,980 gallons of gasoline consumed and contribute the benefits of 2,500 trees planted over the life of your system.'
            }]
          }]
        }]
      }]
    }
  }, {
    type: 'TextBlock', themeClass: 'footer', value: {
      type: 'doc', content: [{
        type: 'paragraph', content: [{
          type: 'text', marks: [{
            type: 'superscript'
          }], text: '1'
        }, {
          type: 'text', text: ' https://www.energy.gov/eere/solar/how-does-solar-work'
        }, {
          type: 'hardBreak'
        }, {
          type: 'text', marks: [{
            type: 'superscript'
          }], text: '2'
        }, {
          type: 'text',
          text: ' 2019 Zillow Study shows solar increases your home value. https://www.zillow.com/research/solar-panels-house-sell-more-23798'
        }]
      }]
    }
  }]
}, {
  type: 'PageBlock', themeClass: 'page', cssStyle: {
    backgroundImage: 'url(https://images.unsplash.com/photo-1560264357-8d9202250f21?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=100)',
    backgroundPosition: 'center center',
    backgroundSize: 'cover',
    display: 'flex',
    flexDirection: 'column'
  }, children: [{
    type: 'TextBlock', themeClass: 'title', value: {
      type: 'doc', content: [{
        type: 'heading', attrs: { level: 1 }, content: [{
          type: 'text', text: 'Why Blue Raven?'
        }]
      }]
    }
  }, {
    type: 'ContainerBlock', cssStyle: {
      color: '#ffffff', flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'end'
    }, children: [{
      type: 'TextBlock', value: {
        type: 'doc', content: [{
          type: 'paragraph', content: [{
            type: 'text',
            text: 'The customer experience separates Blue Raven Solar from the rest of the solar industry. We\'ve been in business for seven years and have over 4,000 5-star reviews and an A+ rating with the BBB.'
          }]
        }, {
          type: 'paragraph', content: [{
            type: 'text',
            text: 'Go with Blue Raven Solar to get the highest quality system and workmanship and learn why developing a high-trust culture is our #1 value.'
          }]
        }]
      }
    }]
  }]
}, {
  type: 'PageBlock', themeClass: 'page', children: [{
    type: 'TextBlock', themeClass: 'title', value: {
      type: 'doc', content: [{
        type: 'heading', attrs: { level: 1 }, content: [{
          type: 'text', text: 'Don\'t Take Our Word For It'
        }]
      }]
    }
  }]
}, {
  type: 'PageBlock', themeClass: 'page', cssStyle: {
    color: '#ffffff',
    backgroundImage: 'url(https://images.unsplash.com/photo-1637100533381-d7e827eafd3d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=100)',
    backgroundPosition: 'center center',
    backgroundSize: 'cover',
    display: 'flex',
    flexDirection: 'column'
  }, children: [{
    type: 'TextBlock', themeClass: 'title', value: {
      type: 'doc', content: [{
        type: 'heading', attrs: { level: 1 }, content: [{
          type: 'text', text: 'Your Panels'
        }]
      }]
    }
  }, {
    type: 'TextBlock', cssStyle: {
      flex: 1
    }, value: {
      type: 'doc', content: [{
        type: 'paragraph', content: [{
          type: 'text',
          text: 'We install premium, tier-1, all-black panels to ensure outstanding system production and give your home a clean, modern appearance. Our panels come with a 25-year warranty and top-rated reliability. They\'ll withstand the elements and the test of time.'
        }]
      }, { type: 'paragraph' }, {
        type: 'paragraph', content: [{
          type: 'text',
          text: 'Your panel layout is unique to you, specifically designed by our experts to optimize your system\'s production and tailored to match the look and feel of your home.'
        }]
      }]
    }
  }]
}, {
  type: 'PageBlock', themeClass: 'page', cssStyle: {
    backgroundImage: 'url(https://www.solarreviews.com/content/company/5144406c81a7da2c43714fb5e81bbaf8fcf5/media/sc_install.jpg)',
    backgroundPosition: 'center center',
    backgroundSize: 'cover',
    display: 'flex',
    flexDirection: 'column'
  }, children: [{
    type: 'TextBlock', themeClass: 'title', value: {
      type: 'doc', content: [{
        type: 'heading', attrs: { level: 1 }, content: [{
          type: 'text', text: 'High-Quality Installation'
        }]
      }]
    }
  }, {
    type: 'TextBlock', cssStyle: {
      color: '#ffffff', flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'end'
    }, value: {
      type: 'doc', content: [{
        type: 'paragraph', content: [{
          type: 'text',
          text: 'Blue Raven Solar provides the fastest and highest-quality installation in the industry. With over 15,000 installations to date, our in-house crews are a cut above any other provider. We use top-quality materials, have a rigorous quality assurance program, and back it up with a workmanship guarantee.'
        }]
      }, {
        type: 'paragraph'
      }, {
        type: 'paragraph', content: [{
          type: 'text',
          text: 'We install our premium panels using a low-profile racking system and run conduit on the interior of the home whenever possible to give your home an attractive, modern upgrade.'
        }]
      }]
    }
  }]
}, {
  type: 'PageBlock', themeClass: 'page', children: [{
    type: 'TextBlock', themeClass: 'title', value: {
      type: 'doc', content: [{
        type: 'heading', attrs: { level: 1 }, content: [{
          type: 'text', text: 'Your Inverter'
        }]
      }]
    }
  }, {
    type: 'ContainerBlock', cssStyle: {
      display: 'flex', flex: 1
    }, children: [{
      type: 'ContainerBlock', children: [{
        type: 'TextBlock', cssStyle: {
          textTransform: 'uppercase'
        }, value: {
          type: 'doc', content: [{
            type: 'heading', attrs: { level: 3 }, content: [{
              type: 'text', text: 'Enphase IQ7+'
            }]
          }]
        }
      }, {
        type: 'TextBlock', value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text',
              text: 'We install premium Enphase® microinverters. In our years of experience, Enphase inverters re the longest-lasting, most reliable, and highest-performing inverter solution on the market.'
            }]
          }, {
            type: 'paragraph', content: [{
              type: 'text',
              text: 'Enphase microinverters have many advantages over other inverter options. They\'re safer, have fewer points of failure, and are easily scalable if you ever decide to expand your system.'
            }]
          }]
        }
      }]
    }, {
      type: 'ImageBlock',
      cssStyle: {
        width: '50vw'
      },
      value: 'https://marvel-b1-cdn.bc0a.com/f00000000183673/enphase.com/sites/default/files/styles/max_size_2800xauto_/public/2021-12/IQ7PLUS-72-2-US-hero%402x.png?itok=O9lso80Y'
    }]
  }, {
    type: 'ContainerBlock', cssStyle: {
      display: 'flex', flex: 1
    }, children: [{
      type: 'ImageBlock',
      cssStyle: {
        width: '35vw'
      },
      value: 'https://marvel-b1-cdn.bc0a.com/f00000000183673/enphase.com/sites/default/files/2021-05/MyEnlighten-app-health_0.png'
    }, {
      type: 'ContainerBlock', children: [{
        type: 'TextBlock', cssStyle: {
          textTransform: 'uppercase'
        }, value: {
          type: 'doc', content: [{
            type: 'heading', attrs: { level: 3 }, content: [{
              type: 'text', text: 'Monitoring your system'
            }]
          }]
        }
      }, {
        type: 'TextBlock', value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text', text: 'With the Enphase Enlighten mobile app, you can:'
            }]
          }, {
            type: 'bulletList', content: [{
              type: 'listItem', content: [{
                type: 'paragraph', content: [{
                  type: 'text', text: 'Monitor each panel\'s production in real time'
                }]
              }]
            }, {
              type: 'listItem', content: [{
                type: 'paragraph', content: [{
                  type: 'text', text: 'View daily, monthly, or annual reports of your system production and usage'
                }]
              }]
            }, {
              type: 'listItem', content: [{
                type: 'paragraph', content: [{
                  type: 'text',
                  text: 'See how much excess power your system is sending back to the grid to credit your utility account'
                }]
              }]
            }]
          }]
        }
      }]
    }]
  }, {
    type: 'TextBlock', themeClass: 'footer', value: {
      type: 'doc', content: [{
        type: 'paragraph', content: [{
          type: 'text', text: 'Enphase, Enphase IQ7+ Micro, and Enphase Enlighten are trademarks of Enphase Energy.'
        }, {
          type: 'hardBreak'
        }, {
          type: 'text', text: 'Blue Raven Solar is not affiliated with Enphase Energy.'
        }]
      }]
    }
  }]
}, {
  type: 'PageBlock', themeClass: 'page', children: [
    {
      type: 'TextBlock', themeClass: 'title', value: {
        type: 'doc', content: [{
          type: 'heading', attrs: { level: 1 }, content: [{
            type: 'text', text: 'Proposed Layout'
          }]
        }]
      }
    }, {
      type: 'ContainerBlock', children: [
        {
          type: 'ImageBlock',
          cssStyle: { display: 'flex', justifyContent: 'center' },
          value: 'https://picsum.photos/800/400'
        }, {
          type: 'ContainerBlock', cssStyle: {
            display: 'flex', marginTop: '20px'
          }, children: [{
            type: 'TextBlock', cssStyle: {
              flex: 1,
              display: 'flex', justifyContent: 'center'
            }, value: {
              type: 'doc', content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', marks: [{
                    type: 'bold'
                  }], text: 'SmartStart'
                }, {
                  type: 'text', marks: [{
                    type: 'bold'
                  }, {
                    type: 'superscript'
                  }], text: 'TM'
                }, {
                  type: 'text', marks: [{
                    type: 'bold'
                  }], text: ' Panel Layout for'
                }, {
                  type: 'text', text: ':'
                }, {
                  type: 'hardBreak'
                }, {
                  type: 'mention', attrs: {
                    id: 'firstName', label: null
                  }
                }, {
                  type: 'text', text: ' '
                }, {
                  type: 'mention', attrs: {
                    id: 'lastName', label: null
                  }
                }, {
                  type: 'hardBreak'
                }, {
                  type: 'mention', attrs: {
                    id: 'address', label: null
                  }
                }]
              }]
            }
          }, {
            type: 'TextBlock', cssStyle: {
              flex: 1,
              display: 'flex', justifyContent: 'center'
            }, value: {
              type: 'doc', content: [{
                type: 'table', content: [{
                  type: 'tableRow', content: [{
                    type: 'tableCell', attrs: {
                      colspan: 1, rowspan: 1
                    }, content: [{
                      type: 'paragraph',

                      content: [{
                        type: 'text', text: 'Total System Size'
                      }]
                    }]
                  }, {
                    type: 'tableCell', attrs: {
                      colspan: 1, rowspan: 1
                    }, content: [{
                      type: 'paragraph', attrs: {
                        textAlign: 'right'
                      }, content: [{
                        type: 'text', text: '10 kW DC'
                      }]
                    }]
                  }]
                }, {
                  type: 'tableRow', content: [{
                    type: 'tableCell', attrs: {
                      colspan: 1, rowspan: 1
                    }, content: [{
                      type: 'paragraph',

                      content: [{
                        type: 'text', text: 'Number of Panels'
                      }]
                    }]
                  }, {
                    type: 'tableCell', attrs: {
                      colspan: 1, rowspan: 1
                    }, content: [{
                      type: 'paragraph', attrs: {
                        textAlign: 'right'
                      }, content: [{
                        type: 'text', text: '25'
                      }]
                    }]
                  }]
                }, {
                  type: 'tableRow', content: [{
                    type: 'tableCell', attrs: {
                      colspan: 1, rowspan: 1
                    }, content: [{
                      type: 'paragraph',

                      content: [{
                        type: 'text', text: 'Yearly Solar Production'
                      }]
                    }]
                  }, {
                    type: 'tableCell', attrs: {
                      colspan: 1, rowspan: 1
                    }, content: [{
                      type: 'paragraph', attrs: {
                        textAlign: 'right'
                      }, content: [{
                        type: 'text', text: '19,839 kWh'
                      }]
                    }]
                  }]
                }, {
                  type: 'tableRow', content: [{
                    type: 'tableCell', attrs: {
                      colspan: 1, rowspan: 1
                    }, content: [{
                      type: 'paragraph',

                      content: [{
                        type: 'text', text: 'Estimated Offset'
                      }]
                    }]
                  }, {
                    type: 'tableCell', attrs: {
                      colspan: 1, rowspan: 1
                    }, content: [{
                      type: 'paragraph', attrs: {
                        textAlign: 'right'
                      }, content: [{
                        type: 'text', text: '90%'
                      }]
                    }]
                  }]
                }]
              }]
            }
          }]
        }]
    }
  ]
}, {
  type: 'PageBlock', themeClass: 'page', children: [{
    type: 'TextBlock', themeClass: 'title', value: {
      type: 'doc', content: [{
        type: 'heading', attrs: { level: 1 }, content: [{
          type: 'text', text: 'Your Savings'
        }]
      }]
    }
  }, {
    type: 'ImageBlock', cssStyle: { textAlign: 'center', margin: '20px 0' }, value: 'https://picsum.photos/400/100'
  }, {
    type: 'ContainerBlock', cssStyle: {
      display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gridTemplateRows: 'repeat(4, 1fr)', flex: 1
    }, children: [{
      type: 'ContainerBlock', cssStyle: {
        display: 'flex',
        flex: 1,
        justifyContent: 'space-around',
        alignItems: 'flex-end',
        gridColumn: '1 / span 4',
        gridRow: '1'
      }, children: [{
        type: 'TextBlock', cssStyle: {
          flex: 1, borderBottom: '1px solid rgb(128,132,133)'
        }, value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text', text: 'Your Bill'
            }]
          }]
        }
      }, {
        type: 'TextBlock', cssStyle: {
          flex: 1, borderBottom: '1px solid rgb(128,132,133)'
        }, value: {
          type: 'doc', content: [{
            type: 'paragraph',

            content: [{
              type: 'text', text: 'Monthly Cost'
            }, {
              type: 'hardBreak'
            }, {
              type: 'text', text: 'Today'
            }]
          }]
        }
      }, {
        type: 'TextBlock', cssStyle: {
          flex: 1, borderBottom: '1px solid rgb(128,132,133)'
        }, value: {
          type: 'doc', content: [{
            type: 'paragraph',

            content: [{
              type: 'text', text: 'Monthly Cost'
            }, {
              type: 'hardBreak'
            }, {
              type: 'text', text: 'in 5 Years'
            }]
          }]
        }
      }, {
        type: 'TextBlock', cssStyle: {
          flex: 1, borderBottom: '1px solid rgb(128,132,133)'
        }, value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text', text: '25 Year Cost'
            }]
          }]
        }
      }]
    }, {
      type: 'ContainerBlock', cssStyle: {
        display: 'flex',
        flex: 1,
        justifyContent: 'space-around',
        alignItems: 'center',
        gridColumn: '1 / span 4',
        gridRow: '2',
        borderBottom: '1px dashed rgb(128,132,133)'
      }, children: [{
        type: 'TextBlock', cssStyle: {
          flex: 1
        }, value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text', text: 'Without Solar'
            }]
          }]
        }
      }, {
        type: 'TextBlock', cssStyle: {
          flex: 1, textAlign: 'center'
        }, value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text', text: 'N/A'
            }]
          }]
        }
      }, {
        type: 'TextBlock', cssStyle: {
          flex: 1, textAlign: 'center'
        }, value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text', text: '$274'
            }]
          }]
        }
      }, {
        type: 'TextBlock', cssStyle: {
          flex: 1, textAlign: 'center'
        }, value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text', text: '$107,969'
            }]
          }]
        }
      }]
    }, {
      type: 'ContainerBlock', cssStyle: {
        display: 'flex',
        flex: 1,
        justifyContent: 'space-around',
        alignItems: 'center',
        gridColumn: '1 / span 3',
        gridRow: '3'
      }, children: [{
        type: 'TextBlock', cssStyle: {
          flex: 1
        }, value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text', text: 'Without Blue Raven SmartStart'
            }]
          }]
        }
      }, {
        type: 'TextBlock', cssStyle: {
          flex: 1, textAlign: 'center'
        }, value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text', text: '$89'
            }]
          }]
        }
      }, {
        type: 'TextBlock', cssStyle: {
          flex: 1, textAlign: 'center'
        }, value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text', text: '$176'
            }]
          }]
        }
      }]
    }, {
      type: 'ContainerBlock', cssStyle: {
        display: 'flex',
        flex: 1,
        justifyContent: 'space-around',
        alignItems: 'center',
        gridColumn: '1 / span 3',
        gridRow: '4',
        color: 'rgb(128,132,133)'
      }, children: [{
        type: 'TextBlock', cssStyle: {
          flex: 1
        }, value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text', text: 'Average Remaining Electric Bill'
            }, {
              type: 'text', marks: [{
                type: 'superscript'
              }], text: '2'
            }]
          }]
        }
      }, {
        type: 'TextBlock', cssStyle: {
          flex: 1, textAlign: 'center'
        }, value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text', text: '$23'
            }]
          }]
        }
      }, {
        type: 'TextBlock', cssStyle: {
          flex: 1, textAlign: 'center'
        }, value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text', text: '$30'
            }]
          }]
        }
      }]
    }, {
      type: 'ContainerBlock', cssStyle: {
        gridColumn: '4',
        gridRow: '3 / span 2',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center'
      }, children: [{
        type: 'TextBlock', value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text', marks: [{
                type: 'bold'
              }], text: '25 Years Savings'
            }, {
              type: 'text', marks: [{
                type: 'superscript'
              }], text: '1'
            }]
          }]
        }
      }, {
        type: 'TextBlock', cssStyle: {
          border: '2px solid rgb(66, 162, 230)',
          borderRadius: '50px',
          textAlign: 'center',
          fontSize: '20px',
          padding: '5px 10px'
        }, value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text', marks: [{
                type: 'bold'
              }], text: '$46,493'
            }]
          }]
        }
      }]
    }]
  }, {
    type: 'TextBlock', themeClass: 'footer', value: {
      type: 'doc', content: [{
        type: 'paragraph', content: [{
          type: 'text', marks: [{
            type: 'superscript'
          }], text: '1'
        }, {
          type: 'text',
          text: 'The cost and savings estimates above assume a utility rate increase of 3.5% per year based on historical averages.'
        }, {
          type: 'hardBreak'
        }, {
          type: 'text', marks: [{
            type: 'superscript'
          }], text: '2'
        }, {
          type: 'text',
          text: 'The average remaining electric bill is an estimate provided as a courtesy by Blue Raven Solar and is based on assumptions about your average electric bill, system offset, electricity usage, and utility rate structure. Offset and remaining electric bill are not guaranteed. All customers will have a utility connection fee.'
        }]
      }]
    }
  }]
}, {
  type: 'PageBlock', themeClass: 'page', cssStyle: { display: 'flex', flexDirection: 'column' }, children: [{
    type: 'TextBlock', themeClass: 'title', value: {
      type: 'doc', content: [{
        type: 'heading', attrs: { level: 1 }, content: [{
          type: 'text', text: 'Payment Options'
        }]
      }]
    }
  },
    {
      type: 'ContainerBlock', cssStyle: { flex: 1, display: 'flex', alignItems: 'center' }, children: [
        {
          type: 'ContainerBlock',
          cssStyle: {
            flex: 1,
            display: 'grid',
            textAlign: 'center',
            alignItems: 'center',
            gridTemplateColumns: '.25fr repeat(4, 1fr)',
            gridTemplateRows: 'repeat(3, 1fr)'
          },
          children: [{
            type: 'ContainerBlock', cssStyle: {
              display: 'flex', justifyContent: 'space-around', gridColumn: '3 / span 3'
            }, children: [{
              type: 'TextBlock', cssStyle: { flex: 1 }, value: {
                type: 'doc', content: [{
                  type: 'paragraph', content: [{ type: 'text', text: 'First 5 Years' }]
                }]
              }
            }, {
              type: 'TextBlock', cssStyle: { flex: 1 }, value: {
                type: 'doc', content: [{
                  type: 'paragraph', content: [{ type: 'text', text: 'Years 6-25' }]
                }]
              }
            }, {
              type: 'TextBlock', cssStyle: { flex: 1 }, value: {
                type: 'doc', content: [{
                  type: 'paragraph', content: [{ type: 'text', text: 'Years 26+' }]
                }]
              }
            }]
          }, {
            type: 'ContainerBlock', cssStyle: {
              display: 'flex', alignItems: 'center', gridColumn: '1', gridRow: '2'
            }, children: [{
              type: 'TextBlock', value: {
                type: 'doc', content: [{
                  type: 'paragraph', content: [{ type: 'text', text: '1.' }]
                }]
              }
            }]
          }, {
            type: 'ContainerBlock', cssStyle: {
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-around',
              gridColumn: '2 / span 4',
              gridRow: '2',
              border: '2px solid rgb(66, 162, 230)',
              borderRadius: '50px',
              padding: '10px'
            }, children: [{
              type: 'TextBlock', cssStyle: { flex: 1, textAlign: 'left' }, value: {
                type: 'doc', content: [{
                  type: 'paragraph', content: [{
                    type: 'text', text: 'Apply all tax credits and rebates to loan'
                  }]
                }]
              }
            }, {
              type: 'TextBlock', cssStyle: { flex: 1 }, value: {
                type: 'doc', content: [{
                  type: 'paragraph', content: [{ type: 'text', text: '$89' }]
                }]
              }
            }, {
              type: 'TextBlock', cssStyle: { flex: 1 }, value: {
                type: 'doc', content: [{
                  type: 'paragraph', content: [{ type: 'text', text: '$176' }]
                }]
              }
            }, {
              type: 'TextBlock', cssStyle: { flex: 1 }, value: {
                type: 'doc', content: [{
                  type: 'paragraph', content: [{ type: 'text', text: '$0' }]
                }]
              }
            }]
          }, {
            type: 'ContainerBlock', cssStyle: {
              display: 'flex', alignItems: 'center', gridColumn: '1', gridRow: '3'
            }, children: [{
              type: 'TextBlock', value: {
                type: 'doc', content: [{
                  type: 'paragraph', content: [{ type: 'text', text: '2.' }]
                }]
              }
            }]
          }, {
            type: 'ContainerBlock', cssStyle: {
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-around',
              gridColumn: '2 / span 4',
              gridRow: '3',
              padding: '10px'
            }, children: [{
              type: 'TextBlock', cssStyle: { flex: 1, textAlign: 'left' }, value: {
                type: 'doc', content: [{
                  type: 'paragraph', content: [{
                    type: 'text', text: 'Use tax credit for something else'
                  }]
                }]
              }
            }, {
              type: 'TextBlock', cssStyle: { flex: 1 }, value: {
                type: 'doc', content: [{
                  type: 'paragraph', content: [{ type: 'text', text: '$89|$150' }]
                }]
              }
            }, {
              type: 'TextBlock', cssStyle: { flex: 1 }, value: {
                type: 'doc', content: [{
                  type: 'paragraph', content: [{ type: 'text', text: '238' }]
                }]
              }
            }, {
              type: 'TextBlock', cssStyle: { flex: 1 }, value: {
                type: 'doc', content: [{
                  type: 'paragraph', content: [{ type: 'text', text: '$0' }]
                }]
              }
            }]
          }]
        }
      ]
    },

    {
      type: 'TextBlock', themeClass: 'footer', value: {
        type: 'doc', content: [{
          type: 'paragraph', content: [{
            type: 'text',
            text: 'If you finance the purchase of your System, the payments presented in Option 1 assume you make a voluntary payment equal to your estimated federal and state incentives. You can voluntarily make additional payments to the lender beyond your federal and state incentives without penalty. Tax and other government or utility incentives vary as to eligibility, participation, and refundability and are subject to change.'
          }]
        }]
      }
    }]
}, {
  type: 'PageBlock', themeClass: 'page', children: [{
    type: 'TextBlock', themeClass: 'title', value: {
      type: 'doc', content: [{
        type: 'heading', attrs: { level: 1 }, content: [{
          type: 'text', text: 'How it Works'
        }]
      }]
    }
  }, {
    type: 'ContainerBlock', cssStyle: {
      display: 'flex', flex: 1
    }, children: [{
      type: 'ContainerBlock', cssStyle: { flex: 1 }, children: [{
        type: 'TextBlock', value: {
          type: 'doc', content: [{
            type: 'paragraph', content: [{
              type: 'text',
              text: 'SmartStart from Blue Raven is the best way to save money with solar from day one. SmartStart offers:'
            }]
          }, {
            type: 'bulletList', content: [{
              type: 'listItem', content: [{
                type: 'paragraph', content: [{
                  type: 'text', text: 'The lowest monthly payment'
                }]
              }]
            }, {
              type: 'listItem', content: [{
                type: 'paragraph', content: [{
                  type: 'text',
                  text: 'The most flexible payment options - no prepayment penalty, optional tax credit paydown, transferability to new homeowner'
                }]
              }]
            }, {
              type: 'listItem', content: [{
                type: 'paragraph', content: [{
                  type: 'text', text: 'The opportunity to save the most money upfront on your utility bills'
                }]
              }]
            }]
          }, {
            type: 'paragraph', content: [{
              type: 'text',
              text: 'The first 18-month solar payment is a low, promotional amount offered by the lender. The SmartStart program from Blue Raven Solar extends the promotion an additional 42 months by sending you a monthly check to keep your payment the same. This unique 5 year offer is exclusively from Blue Raven Solar.'
            }]
          }]
        }
      }]
    }, {
      type: 'ContainerBlock', cssStyle: { flex: 1 }, children: [{
        type: 'TextBlock', value: {
          type: 'doc', content: [{
            type: 'table', content: [{
              type: 'tableRow', content: [{
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: 'Total System Size'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph', attrs: {
                    textAlign: 'right'
                  }, content: [{
                    type: 'text', text: '10 kW DC'
                  }]
                }]
              }]
            }, {
              type: 'tableRow', content: [{
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: 'Yearly Solar Production'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph', attrs: {
                    textAlign: 'right'
                  }, content: [{
                    type: 'text', text: '19,839 kWh'
                  }]
                }]
              }]
            }, {
              type: 'tableRow', content: [{
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: 'Total System Cost'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph', attrs: {
                    textAlign: 'right'
                  }, content: [{
                    type: 'text', text: '$54,141'
                  }]
                }]
              }]
            }, {
              type: 'tableRow', content: [{
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: 'Referral Promotion'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph', attrs: {
                    textAlign: 'right'
                  }, content: [{
                    type: 'text', text: '($500)'
                  }]
                }]
              }]
            }]
          }, {
            type: 'horizontalRule'
          }, {
            type: 'table', content: [{
              type: 'tableRow', content: [{
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: 'Total Loan Amount'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph', attrs: {
                    textAlign: 'right'
                  }, content: [{
                    type: 'text', text: '$53,641'
                  }]
                }]
              }]
            }, {
              type: 'tableRow', content: [{
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: 'Federal Tax Credit (26%)'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph', attrs: {
                    textAlign: 'right'
                  }, content: [{
                    type: 'text', text: '$13,947'
                  }]
                }]
              }]
            }]
          }, {
            type: 'horizontalRule'
          }, {
            type: 'table', content: [{
              type: 'tableRow', content: [{
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: 'Net System Cost'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph', attrs: {
                    textAlign: 'right'
                  }, content: [{
                    type: 'text', text: '$53,641'
                  }]
                }]
              }]
            }]
          }]
        }
      }]
    }]
  }, {
    type: 'TextBlock', themeClass: 'footer', value: {
      type: 'doc', content: [{
        type: 'paragraph', content: [{
          type: 'text',
          text: 'SmartStart is available to new Blue Raven Solar customers who finance the purchase of their solar system from the Company\'s preferred lender, GoodLeap, LLC. Eligibility is determined by application.'
        }]
      }]
    }
  }]
}, {
  type: 'PageBlock', themeClass: 'page', children: [{
    type: 'TextBlock', themeClass: 'title', value: {
      type: 'doc', content: [{
        type: 'heading', attrs: { level: 1 }, content: [{
          type: 'text', text: 'System Assumptions'
        }]
      }]
    }
  }, {
    type: 'ContainerBlock', cssStyle: { display: 'flex' }, children: [{
      type: 'TextBlock', cssStyle: { flex: 1 }, value: {
        type: 'doc', content: [{
          type: 'heading', attrs: {
            level: 3

          }, content: [{
            type: 'text', text: 'Utility Assumptions'
          }]
        }, {
          type: 'table', content: [{
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Utility Company'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Xcel Energy'
                }]
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Current Annual Consumption'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '22,000 kWh'
                }]
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Current Estimated Annual Utility Bill'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '$2,727'
                }]
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Current Estimated Cost per kWh'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '$0.126'
                }]
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Annual Utility Cost Escalator'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '3.5%'
                }]
              }]
            }]
          }]
        }, {
          type: 'heading', attrs: {
            level: 3

          }, content: [{
            type: 'text', text: 'System Assumptions'
          }]
        }, {
          type: 'table', content: [{
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'System Size (kW)'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '10 kW DC'
                }]
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Year 1 System Production (kWh)'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '19,839 kWh'
                }]
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Annual System Degradation'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '0.25%'
                }]
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '25-Year System Production (kWh)'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '481,377 kWh'
                }]
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Estimated Offset'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '90%'
                }]
              }]
            }]
          }]
        }, {
          type: 'heading', attrs: {
            level: 3

          }, content: [{
            type: 'text', text: 'System Cost Assumptions'
          }]
        }, {
          type: 'table', content: [{
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Total System Cost'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '$54,141'
                }]
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Blue Raven Solar Referral Promotion Down Payment'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '($500)'
                }]
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Total Loan Amount'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '$53,641'
                }]
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Federal Tax Incentive ($)'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '$13,947'
                }]
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Sales Tax Incentive ($)'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph', attrs: {}
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Other Incentive'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph', attrs: {}
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'APR'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '1.98%'
                }]
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Loan Term'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '25'
                }]
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'Assumed Payment by Month 18'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '$13,947'
                }]
              }]
            }]
          }, {
            type: 'tableRow', content: [{
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: 'SmartStart Months 19-60 Rebate'
                }]
              }]
            }, {
              type: 'tableCell', attrs: {
                colspan: 1, rowspan: 1
              }, content: [{
                type: 'paragraph',

                content: [{
                  type: 'text', text: '$87.64 / month'
                }]
              }]
            }]
          }]
        }]
      }
    }, {
      type: 'ContainerBlock', cssStyle: {
        flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center'
      }, children: [{
        type: 'TextBlock', value: {
          type: 'doc', content: [{
            type: 'heading', attrs: {

              level: 3
            }, content: [{
              type: 'text', text: 'SmartStart Option 1 Detail'
            }]
          }, {
            type: 'table', content: [{
              type: 'tableRow', content: [{
                type: 'tableHeader', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: 'Apply All Tax Credits and Rebates to Loan'
                  }]
                }]
              }, {
                type: 'tableHeader', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: 'Monthly Loan Amount'
                  }]
                }]
              }, {
                type: 'tableHeader', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: 'Check From Blue Raven'
                  }]
                }]
              }, {
                type: 'tableHeader', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: 'Net Payment From Customer'
                  }]
                }]
              }]
            }, {
              type: 'tableRow', content: [{
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: 'Months 0-18'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: '$88.51'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: '$0.00'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: '$88.51'
                  }]
                }]
              }]
            }, {
              type: 'tableRow', content: [{
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: 'Months 19-60'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: '$176.15'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: '$87.64'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: '$88.51'
                  }]
                }]
              }]
            }, {
              type: 'tableRow', content: [{
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: 'Months 61+'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: '$176.15'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: '$0.00'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: '$176.15'
                  }]
                }]
              }]
            }]
          }]
        }
      }, {
        type: 'TextBlock', value: {
          type: 'doc', content: [{
            type: 'heading', attrs: {
              level: 3

            }, content: [{
              type: 'text', text: 'Energy Efficiency Upgrades'
            }]
          }, {
            type: 'table', content: [{
              type: 'tableRow', content: [{
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: 'LED Light Bulbs'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: '0'
                  }]
                }]
              }]
            }, {
              type: 'tableRow', content: [{
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: 'Ecobee3 Smart Thermostats'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', text: '0'
                  }]
                }]
              }]
            }, {
              type: 'tableRow', content: [{
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', marks: [{
                      type: 'bold'
                    }], text: 'Total EE Reduction'
                  }]
                }]
              }, {
                type: 'tableCell', attrs: {
                  colspan: 1, rowspan: 1
                }, content: [{
                  type: 'paragraph',

                  content: [{
                    type: 'text', marks: [{
                      type: 'bold'
                    }], text: '0 kwH'
                  }]
                }]
              }]
            }]
          }]
        }
      }]
    }]
  }, {
    type: 'TextBlock', themeClass: 'footer', value: {
      type: 'doc', content: [{
        type: 'paragraph', content: [{
          type: 'text', text: 'No Prepayment Penalties to Maximize Savings'
        }]
      }, {
        type: 'paragraph', content: [{
          type: 'text',
          text: 'Your loan agreement may assume a voluntary payment equal to your estimated federal tax incentive. You can voluntarily pay more than this minimum voluntary payment with no prepayment penalties. Talk to your lender for more details.'
        }]
      }, {
        type: 'paragraph', content: [{
          type: 'text', marks: [{
            type: 'bold'
          }], text: 'Solar System Lifespan'
        }]
      }, {
        type: 'paragraph', content: [{
          type: 'text',
          text: 'Most solar systems can be productive for 30-35 years or more and their primary operating components come with long-term manufacturers\' warranties.'
        }]
      }, {
        type: 'paragraph', content: [{
          type: 'text', marks: [{
            type: 'bold'
          }], text: 'Net Metering'
        }]
      }, {
        type: 'paragraph', content: [{
          type: 'text',
          text: 'At times, your solar energy system will produce more electricity than you use and the surplus electricity is returned to the utility grid to be used by other consumers. This process is called "net metering," and it effectively credits you for the excess production and bills you for the net amount of electricity you have used from the grid.'
        }]
      }]
    }
  }]
}]

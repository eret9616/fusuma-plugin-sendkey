# frozen_string_literal: true

require "spec_helper"

require "./lib/fusuma/plugin/sendkey/keyboard"

module Fusuma
  module Plugin
    module Sendkey
      RSpec.describe Keyboard do
        describe "#new" do
          subject { Keyboard.new }

          context "when keyboard is found" do
            before do
              dummy_keyboard = Fusuma::Device.new(name: "dummy keyboard")
              allow(Keyboard)
                .to receive(:find_device)
                .and_return(dummy_keyboard)
              allow(Sendkey::Device).to receive(:new).and_return("dummy")
            end

            it { is_expected.to be_a Keyboard }
          end

          context "when keyboard is not found" do
            before do
              allow(Keyboard).to receive(:find_device).and_return(nil)
            end

            it { expect { subject }.to raise_error(SystemExit) }
          end

          context "when detected device name is Keyboard (Capitarized)" do
            before do
              other_device = Fusuma::Device.new(name: "Keyboard (Capitarized)", id: "dummy")

              allow(Keyboard)
                .to receive(:find_device)
                .and_return(other_device)
              allow(Sendkey::Device).to receive(:new).and_return("dummy")
            end

            it { is_expected.to be_a Keyboard }
          end

          context "when detected device name is KEYBOARD (UPPER CASE)" do
            before do
              other_device = Fusuma::Device.new(name: "KEYBOARD(UPPER CASE)", id: "dummy")
              allow(Keyboard)
                .to receive(:find_device)
                .and_return(other_device)
              allow(Sendkey::Device).to receive(:new).and_return("dummy")
            end

            it { is_expected.to be_a Keyboard }
          end

          context "with given name pattern" do
            subject { Keyboard.new(name_pattern: "Awesome KEY/BOARD") }

            before do
              specified_device = Fusuma::Device.new(
                name: "Awesome KEY/BOARD input device",
                id: "dummy",
                capabilities: "keyboard"
              )
              allow(Fusuma::Device).to receive(:all).and_return([specified_device])
              allow(Sendkey::Device).to receive(:new).and_return("dummy")
            end

            it { is_expected.to be_a Keyboard }
          end

          context "when name pattern (use default) is not given" do
            subject { Keyboard.new(name_pattern: nil) }

            before do
              allow(Sendkey::Device).to receive(:new).and_return("dummy")
            end

            context "when exist device named keyboard(lower-case)" do
              before do
                specified_device = Fusuma::Device.new(
                  name: "keyboard",
                  id: "dummy",
                  capabilities: "keyboard"
                )
                allow(Fusuma::Device).to receive(:all).and_return([specified_device])
              end

              it { is_expected.to be_a Keyboard }
            end

            context "when exist device named Keyboard(Capital-case)" do
              before do
                specified_device = Fusuma::Device.new(
                  name: "Keyboard",
                  id: "dummy",
                  capabilities: "keyboard"
                )
                allow(Fusuma::Device).to receive(:all).and_return([specified_device])
              end

              it { is_expected.to be_a Keyboard }
            end

            context "when exist device named KEYBOARD(UPPER case)" do
              before do
                specified_device = Fusuma::Device.new(
                  name: "KEYBOARD",
                  id: "dummy",
                  capabilities: "keyboard"
                )
                allow(Fusuma::Device).to receive(:all).and_return([specified_device])
              end

              it { is_expected.to be_a Keyboard }
            end

            context "when exist no device named keyboard|Keyboard|KEYBOARD" do
              before do
                specified_device = Fusuma::Device.new(
                  name: "KEY-BOARD",
                  id: "dummy",
                  capabilities: "keyboard"
                )
                allow(Fusuma::Device).to receive(:all).and_return([specified_device])
              end

              it { is_expected.to be_a Keyboard }
            end
          end
        end

        describe "#type" do
          subject { @keyboard.type(param: @keys, keep: @keep, clear: @clear) }

          before do
            allow(Keyboard)
              .to receive(:find_device)
              .and_return(Fusuma::Device.new(name: "dummy keyboard"))

            @device = instance_double(Sendkey::Device)
            allow(@device).to receive(:write_event).with(anything)

            allow(Sendkey::Device).to receive(:new).and_return(@device)

            @keyboard = Keyboard.new
            @keys = ""
            @keep = ""
            @clear = :none
          end

          it "presses key KEY_A and release KEY_A" do
            @keys = "A"
            expect(@keyboard).to receive(:clear_modifiers).ordered
            expect(@keyboard).to receive(:send_event).with(code: "KEY_A", press: true).ordered
            expect(@keyboard).to receive(:send_event).with(code: "KEY_A", press: false).ordered
            subject
          end

          context "with modifier keys" do
            before do
              @keys = "LEFTSHIFT+A"
            end

            it "types (Shift)A" do
              expect(@keyboard).to receive(:clear_modifiers).with([]).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_LEFTSHIFT", press: true).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_A", press: true).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_A", press: false).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_LEFTSHIFT", press: false).ordered
              subject
            end

            context "with keep option" do
              before do
                @keep = "LEFTSHIFT"
              end
              it "types (Shift)A and skip press and release LEFTSHIFT" do
                expect(@keyboard).to receive(:clear_modifiers).with([]).ordered
                expect(@keyboard).to receive(:send_event).with(code: "KEY_A", press: true).ordered
                expect(@keyboard).to receive(:send_event).with(code: "KEY_A", press: false).ordered
                subject
              end

              context "with clear option" do
                before do
                  @clear = true
                end

                it "clear modifiers without LEFTSHIFT" do
                  expect(@keyboard).to receive(:clear_modifiers).with(Keyboard::MODIFIER_KEY_CODES - ["KEY_LEFTSHIFT"]).ordered
                  expect(@keyboard).to receive(:send_event).with(code: "KEY_A", press: true).ordered
                  expect(@keyboard).to receive(:send_event).with(code: "KEY_A", press: false).ordered
                  subject
                end
              end
            end

            context "with clear option" do
              before do
                @clear = true
              end

              it "clear modifiers without LEFTSHIFT" do
                expect(@keyboard).to receive(:clear_modifiers).with(Keyboard::MODIFIER_KEY_CODES - ["KEY_LEFTSHIFT"]).ordered
                expect(@keyboard).to receive(:send_event).with(code: "KEY_LEFTSHIFT", press: true).ordered
                expect(@keyboard).to receive(:send_event).with(code: "KEY_A", press: true).ordered
                expect(@keyboard).to receive(:send_event).with(code: "KEY_A", press: false).ordered
                expect(@keyboard).to receive(:send_event).with(code: "KEY_LEFTSHIFT", press: false).ordered
                subject
              end
            end
          end

          context "with multiple keys" do
            before do
              @keys = "A+B"
            end

            it "types AB" do
              expect(@keyboard).to receive(:clear_modifiers).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_A", press: true).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_B", press: true).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_B", press: false).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_A", press: false).ordered
              subject
            end
          end

          context "with keep(keypress) option" do
            context "when keypress modifier key contains a sendkey parameter" do
              before do
                @keep = "LEFTMETA"
                @keys = "LEFTMETA+LEFT"
              end

              it "sends KEY_LEFT (without clearng or sending KEY_LEFTMETA which pressing by user)" do
                expect(@keyboard).to receive(:clear_modifiers).with([]).ordered
                expect(@keyboard).to receive(:keydown).with("KEY_LEFT").ordered
                expect(@keyboard).to receive(:keyup).with("KEY_LEFT").ordered
                subject
              end

              context "with clear option" do
                before do
                  @clear = true
                end
                it "clear modifiers without LEFTMETA" do
                  expect(@keyboard).to receive(:clear_modifiers).with(Keyboard::MODIFIER_KEY_CODES - ["KEY_LEFTMETA"]).ordered
                  expect(@keyboard).to receive(:keydown).with("KEY_LEFT").ordered
                  expect(@keyboard).to receive(:keyup).with("KEY_LEFT").ordered
                  subject
                end
              end
            end

            context "when keypress modifier key does NOT contains a sendkey parameter" do
              before do
                @keep = "LEFTALT"
                @keys = "BRIGHTNESSUP"
              end

              it "sends KEY_BRIGHTNESSUP (and clear KEY_LEFTALT pressing by user)" do
                expect(@keyboard).to receive(:keydown).with("KEY_BRIGHTNESSUP").ordered
                expect(@keyboard).to receive(:keyup).with("KEY_BRIGHTNESSUP").ordered
                subject
              end

              context "with clear option" do
                before do
                  @clear = true
                end
                it "clear modifiers without LEFTALT" do
                  expect(@keyboard).to receive(:clear_modifiers).with(array_including("KEY_LEFTALT")).ordered
                  expect(@keyboard).to receive(:keydown).with("KEY_BRIGHTNESSUP").ordered
                  expect(@keyboard).to receive(:keyup).with("KEY_BRIGHTNESSUP").ordered
                  subject
                end
              end
            end
          end
        end

        describe "#types" do
          subject { @keyboard.types(@args) }
          context "with multiple keys(Array)" do
            before do
              allow(Keyboard)
                .to receive(:find_device)
                .and_return(Fusuma::Device.new(name: "dummy keyboard"))

              @device = instance_double(Sendkey::Device)
              allow(@device).to receive(:write_event).with(anything)

              allow(Sendkey::Device).to receive(:new).and_return(@device)

              @keyboard = Keyboard.new
              @args = ["LEFTSHIFT+F10", "T", "ENTER", "ESC"]
            end

            it "types LEFTSHIFT+F10, T, ENTER, ESC" do
              expect(@keyboard).to receive(:send_event).with(code: "KEY_LEFTSHIFT", press: true).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_F10", press: true).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_F10", press: false).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_LEFTSHIFT", press: false).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_T", press: true).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_T", press: false).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_ENTER", press: true).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_ENTER", press: false).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_ESC", press: true).ordered
              expect(@keyboard).to receive(:send_event).with(code: "KEY_ESC", press: false).ordered
              subject
            end
          end
        end
      end
    end
  end
end

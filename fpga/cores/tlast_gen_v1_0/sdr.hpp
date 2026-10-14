/// Pulse driver
///
/// (c) Koheron

#ifndef __DRIVERS_PULSE_HPP__
#define __DRIVERS_PULSE_HPP__

#include <atomic>
#include <thread>
#include <chrono>

#include <context.hpp>

// http://www.xilinx.com/support/documentation/ip_documentation/axi_fifo_mm_s/v4_1/pg080-axi-fifo-mm-s.pdf
namespace Fifo_regs {
    constexpr uint32_t rdfr = 0x18;
    constexpr uint32_t rdfo = 0x1C;
    constexpr uint32_t rdfd = 0x20;
    constexpr uint32_t rlr = 0x24;
}

//constexpr uint32_t dac_size = mem::dac_range/sizeof(uint32_t);


class Sdr
{
  public:
    Pulse(Context& ctx)
    : ctl(ctx.mm.get<mem::control>())
    , sts(ctx.mm.get<mem::status>())
    , adc_fifo_map(ctx.mm.get<mem::adc_fifo>())
    , dac_map(ctx.mm.get<mem::dac>())
    {
        start_fifo_acquisition();
    }

    // Radoi Config
    auto get_receieve_frequency()
    {
        return receive frequency;
    }

    void set_receive_frequency(uint32_t, receive_frequency_set){
        recive_frequency_set = uint32_t(receive_frequency_set*14.36);
        ctl.write<reg::receive_frequency>(receive_frequency_set);
        receive_frequency = receive_frequency_set;
    }

    void set_volume(uint32_t volume_set){
        ctl.write<reg::volume>(volume_set);
        volume = volume_set;
    }

    // Radio State

    uint32_t get_signal_strength() {
        return sts.read<reg::signal_strength>();
    }
    
    // Adc FIFO

    uint32_t get_fifo_occupancy() {
        return adc_fifo_map.read<Fifo_regs::rdfo>();
    }

    void reset_fifo() {
        adc_fifo_map.write<Fifo_regs::rdfr>(0x000000A5);
    }

    uint32_t read_fifo() {
        return adc_fifo_map.read<Fifo_regs::rdfd>();
    }

    uint32_t get_fifo_length() {
        return (adc_fifo_map.read<Fifo_regs::rlr>() & 0x3FFFFF) >> 2;
    }

    void wait_for(uint32_t n_pts) {
        do {} while (get_fifo_length() < n_pts);
    }

    std::vector<uint32_t>& get_next_pulse(uint32_t n_pts) {

        fifo_acquisition_started = false;

        adc_data.resize(n_pts);

        if (n_pts == 0)
            return adc_data;

        wait_for(1);
        uint32_t data = read_fifo();

        // Wait for the beginning of a pulse
        while ((data & (1 << 15)) != (1 << 15)) {
            wait_for(1);
            data = read_fifo();
        }

        adc_data[0] = data;
        wait_for(n_pts -1);

        for (unsigned int i=1; i < n_pts; i++)
            adc_data[i] = read_fifo();
        return adc_data;
    }

    const auto& get_fifo_buffer() {
        return fifo_buffer;
    }

    void start_fifo_acquisition();

  private:
    Memory<mem::control>& ctl;
    Memory<mem::status>& sts;
    Memory<mem::adc_fifo>& adc_fifo_map;
    Memory<mem::dac>& dac_map;

    uint32_t pulse_width;
    uint32_t pulse_period;

    std::vector<uint32_t> adc_data;


    static constexpr uint32_t fifo_buff_size = 1024;

    std::array<uint32_t, fifo_buff_size> fifo_buffer;

    std::atomic<bool> fifo_acquisition_started{false};
    std::atomic<uint32_t> fifo_buff_idx{0};

    std::thread fifo_thread;
    void fifo_acquisition_thread();

};

inline void Pulse::start_fifo_acquisition() {
    if (! fifo_acquisition_started) {
        fifo_buffer.fill(0);
        fifo_thread = std::thread{&Pulse::fifo_acquisition_thread, this};
        fifo_thread.detach();
    }
}

inline void Pulse::fifo_acquisition_thread()
{
    constexpr auto fifo_sleep_for = std::chrono::microseconds(5000);

    fifo_acquisition_started = true;

    while (fifo_acquisition_started) {
        const uint32_t n_pts = get_fifo_length();

        for (size_t i = 0; i < n_pts; i++) {
            fifo_buffer[fifo_buff_idx] = read_fifo();
            fifo_buff_idx = (fifo_buff_idx + 1) % fifo_buff_size;
        }
        std::this_thread::sleep_for(fifo_sleep_for);
    }
}

#endif // __DRIVERS_PULSE_HPP__
